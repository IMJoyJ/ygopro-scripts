--奇動装置メイルファクター
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，可以从以下效果选择1个发动。
-- ●以自己场上1只表侧表示怪兽为对象，把这张卡当作装备卡使用给那只怪兽装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备的这张卡特殊召唤。
-- ②：给怪兽装备的这张卡被破坏送去墓地的场合才能发动。这张卡特殊召唤。
function c81951640.initial_effect(c)
	-- 为卡片注册同盟怪兽的标准机制，包括装备、代替破坏以及从装备状态特殊召唤的效果
	aux.EnableUnionAttribute(c,aux.TRUE)
	-- 这个卡名的②的效果1回合只能使用1次。②：给怪兽装备的这张卡被破坏送去墓地的场合才能发动。这张卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(81951640,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,81951640)
	e4:SetCondition(c81951640.con)
	e4:SetTarget(c81951640.tg)
	e4:SetOperation(c81951640.op)
	c:RegisterEffect(e4)
end
-- 检查发动条件：自身因破坏从魔法与陷阱区域送去墓地，且之前有装备对象，并且不是因为失去装备对象而破坏
function c81951640.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_SZONE) and c:GetPreviousEquipTarget() and not c:IsReason(REASON_LOST_TARGET)
end
-- 定义效果的发动准备，检查自身是否可以特殊召唤以及怪兽区域是否有空位
function c81951640.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息，表明该效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义效果的处理逻辑，若自身仍存在于原本位置，则将其特殊召唤
function c81951640.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

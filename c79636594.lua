--ブロック・スパイダー
-- 效果：
-- 「积木蜘蛛」的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，对方不能把其他的昆虫族怪兽作为攻击对象。
-- ②：这张卡特殊召唤成功的场合才能发动。从卡组把1只「积木蜘蛛」特殊召唤。
function c79636594.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，对方不能把其他的昆虫族怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c79636594.bttg)
	c:RegisterEffect(e1)
	-- 「积木蜘蛛」的②的效果1回合只能使用1次。②：这张卡特殊召唤成功的场合才能发动。从卡组把1只「积木蜘蛛」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79636594,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,79636594)
	e2:SetTarget(c79636594.sptg)
	e2:SetOperation(c79636594.spop)
	c:RegisterEffect(e2)
end
-- 过滤不能被选择为攻击对象的怪兽：表侧表示、昆虫族且不是自身
function c79636594.bttg(e,c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c~=e:GetHandler()
end
-- 过滤卡组中卡名为「积木蜘蛛」且可以特殊召唤的卡
function c79636594.filter(c,e,tp)
	return c:IsCode(79636594) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备（检查怪兽区域空位数以及卡组中是否存在可特殊召唤的「积木蜘蛛」）
function c79636594.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足特殊召唤条件的「积木蜘蛛」
		and Duel.IsExistingMatchingCard(c79636594.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示此效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理（从卡组特殊召唤1只「积木蜘蛛」）
function c79636594.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身场上是否有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送选择特殊召唤卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的「积木蜘蛛」
	local g=Duel.SelectMatchingCard(tp,c79636594.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到发动效果玩家的场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--冥帝従騎エイドス
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以上级召唤。
-- ②：把墓地的这张卡除外，以「冥帝从骑 哀多斯」以外的自己墓地1只攻击力800/守备力1000的怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
function c59463312.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59463312,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c59463312.sumop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外，以「冥帝从骑 哀多斯」以外的自己墓地1只攻击力800/守备力1000的怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(59463312,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,59463312)
	-- 把墓地的这张卡除外作为发动成本
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c59463312.target)
	e3:SetOperation(c59463312.operation)
	c:RegisterEffect(e3)
end
-- 召唤·特殊召唤成功时效果的处理：为玩家注册在通常召唤外可以追加1次上级召唤的效果，并注册已发动标识
function c59463312.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查该回合是否已适用过此卡的效果，若已适用则不再重复适用
	if Duel.GetFlagEffect(tp,59463312)~=0 then return end
	-- 这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以上级召唤。/以「冥帝从骑 哀多斯」以外的自己墓地1只攻击力800/守备力1000的怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(59463312,2))  --"使用「冥帝从骑 哀多斯」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetValue(0x1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册增加通常召唤（上级召唤）次数的效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_EXTRA_SET_COUNT)
	-- 给玩家注册增加通常召唤（盖放）次数的效果
	Duel.RegisterEffect(e2,tp)
	-- 给玩家注册该效果本回合已适用的标识，持续到回合结束
	Duel.RegisterFlagEffect(tp,59463312,RESET_PHASE+PHASE_END,0,1)
end
-- 过滤条件：自己墓地中「冥帝从骑 哀多斯」以外的、攻击力800且守备力1000、可以守备表示特殊召唤的怪兽
function c59463312.filter(c,e,tp)
	return c:IsAttack(800) and c:IsDefense(1000) and not c:IsCode(59463312) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②的发动准备：检查是否满足发动条件，并进行取对象处理
function c59463312.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c59463312.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在除这张卡以外、满足过滤条件的怪兽
		and Duel.IsExistingTarget(c59463312.filter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c59463312.filter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 设置连锁信息：包含特殊召唤分类，操作对象为选择的怪兽，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理：将选择的怪兽守备表示特殊召唤，并注册直到回合结束时不能从额外卡组特殊召唤怪兽的限制
function c59463312.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取在发动时选择的对象怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将该怪兽以表侧守备表示特殊召唤到自己场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c59463312.splimit)
	-- 给玩家注册不能从额外卡组特殊召唤怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：限制特殊召唤的怪兽来源为额外卡组
function c59463312.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end

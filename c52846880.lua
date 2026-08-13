--カタストルの影霊衣
-- 效果：
-- 「影灵衣」仪式魔法卡降临
-- 这张卡若非以只使用除「灾亡虫之影灵衣」以外的怪兽来作的仪式召唤则不能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：把这张卡从手卡丢弃，以自己墓地1只「影灵衣」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：自己的「影灵衣」怪兽和从额外卡组特殊召唤的怪兽进行战斗的伤害步骤开始时发动。那只怪兽破坏。
function c52846880.initial_effect(c)
	c:EnableReviveLimit()
	-- 「影灵衣」仪式魔法卡降临；这张卡若非以只使用除「灾亡虫之影灵衣」以外的怪兽来作的仪式召唤则不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件设置为只允许仪式召唤方式（检查召唤类型为仪式召唤），对应效果文本中的『「影灵衣」仪式魔法卡降临』。
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：把这张卡从手卡丢弃，以自己墓地1只「影灵衣」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52846880,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,52846880)
	e2:SetCost(c52846880.spcost)
	e2:SetTarget(c52846880.sptg)
	e2:SetOperation(c52846880.spop)
	c:RegisterEffect(e2)
	-- ②：自己的「影灵衣」怪兽和从额外卡组特殊召唤的怪兽进行战斗的伤害步骤开始时发动。那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(52846880,1))  --"怪兽破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c52846880.condition)
	e3:SetTarget(c52846880.target)
	e3:SetOperation(c52846880.operation)
	c:RegisterEffect(e3)
end
-- 仪式召唤素材过滤：素材不能包含「灾亡虫之影灵衣」自身，即只能使用除这张卡以外的怪兽作为仪式素材。
function c52846880.mat_filter(c)
	return not c:IsCode(52846880)
end
-- ①效果的发动代价：从手卡丢弃这张卡（检查其能否丢弃，若能则执行丢弃）。
function c52846880.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将作为代价的这张卡从手卡送去墓地，丢弃原因标注为代价（REASON_COST）和丢弃（REASON_DISCARD）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 特殊召唤对象过滤：墓地中符合条件的是「影灵衣」怪兽，且可以被当前效果特殊召唤。
function c52846880.spfilter(c,e,tp)
	return c:IsSetCard(0xb4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件与对象选择：需要我方主要怪兽区有空位，且墓地存在符合条件的「影灵衣」怪兽；发动时选择其中1只为对象。
function c52846880.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c52846880.spfilter(chkc,e,tp) end
	-- 效果发动时（chk==0）检查：我方主要怪兽区是否有可用空格，作为发动条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查墓地是否存在至少1只符合条件的「影灵衣」怪兽可以作为特殊召唤对象。
		and Duel.IsExistingTarget(c52846880.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示消息（用于选择对象的提示）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的「影灵衣」怪兽作为效果对象（同时将该卡登记为当前连锁的对象）。
	local g=Duel.SelectTarget(tp,c52846880.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果将进行特殊召唤，对象为已选择的墓地怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：将作为对象的墓地怪兽特殊召唤到我方场上。
function c52846880.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象（发动时选择的墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将那只墓地怪兽以表侧表示特殊召唤到我方场上（不进行召唤条件/苏生限制的检查）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的触发条件：当自己场上的「影灵衣」怪兽与从额外卡组特殊召唤的怪兽进行战斗时，在伤害步骤开始时满足条件；记录对方那只怪兽。
function c52846880.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 取得攻击怪兽。
	local tc=Duel.GetAttacker()
	-- 取得被攻击的怪兽（若攻击怪兽是对方的，则交换变量，使tc为己方「影灵衣」怪兽、bc为对方从额外卡组特殊召唤的怪兽）。
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	if tc:IsControler(1-tp) then tc,bc=bc,tc end
	if tc:IsSetCard(0xb4) and bc:IsSummonLocation(LOCATION_EXTRA) then
		e:SetLabelObject(bc)
		return true
	else return false end
end
-- ②效果的时点确定：满足条件即必发，无需选择对象；设置将破坏的对象为那只与「影灵衣」怪兽战斗的从额外卡组特殊召唤的怪兽。
function c52846880.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetLabelObject()
	-- 设置操作信息：本次效果将破坏对象怪兽，类别为破坏（CATEGORY_DESTROY）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
-- ②效果处理：若那只怪兽仍与本次战斗关联，则将其破坏。
function c52846880.operation(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() then
		-- 将该怪兽以效果原因（REASON_EFFECT）破坏。
		Duel.Destroy(bc,REASON_EFFECT)
	end
end

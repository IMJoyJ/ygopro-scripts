--F.A.ウィナーズ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上有「方程式运动员」怪兽存在的场合，这张卡不会被对方的效果破坏。
-- ②：持有比原本等级高5星以上的等级的自己的「方程式运动员」怪兽用和对方怪兽的战斗给与对方战斗伤害时才能发动。选自己的手卡·场上·墓地1张卡除外。「方程式运动员胜利团队」的效果除外的自己的「方程式运动员」场地魔法3种类齐集时，自己决斗胜利。
function c69553552.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上有「方程式运动员」怪兽存在的场合，这张卡不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c69553552.indcon)
	-- 设置不会被对方的效果破坏。
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ②：持有比原本等级高5星以上的等级的自己的「方程式运动员」怪兽用和对方怪兽的战斗给与对方战斗伤害时才能发动。选自己的手卡·场上·墓地1张卡除外。「方程式运动员胜利团队」的效果除外的自己的「方程式运动员」场地魔法3种类齐集时，自己决斗胜利。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,69553552)
	e3:SetCondition(c69553552.rmcon)
	e3:SetTarget(c69553552.rmtg)
	e3:SetOperation(c69553552.rmop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的「方程式运动员」怪兽。
function c69553552.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107)
end
-- 效果①的启用条件：自己场上存在「方程式运动员」怪兽。
function c69553552.indcon(e)
	-- 检查自己场上是否存在表侧表示的「方程式运动员」怪兽。
	return Duel.IsExistingMatchingCard(c69553552.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 效果②的发动条件：持有比原本等级高5星以上的自己的「方程式运动员」怪兽与对方怪兽战斗并给与对方战斗伤害。
function c69553552.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	local d=a:GetBattleTarget()
	if not d then return false end
	if not a:IsControler(tp) then a,d=d,a end
	return a:IsControler(tp) and a:IsSetCard(0x107)
		and a:GetLevel()-a:GetOriginalLevel()>=5
		and ep~=tp
end
-- 效果②的发动准备（检查是否可以除外卡片并设置操作信息）。
function c69553552.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的手卡、场上、墓地是否存在可以除外的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) end
	-- 设置效果处理信息：从手卡、场上或墓地除外1张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 效果②的效果处理：除外1张卡，并检查是否满足胜利条件。
function c69553552.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己的手卡、场上、墓地选择1张可以除外的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选中的卡表侧表示除外，并判断该卡是否为「方程式运动员」场地魔法并成功除外。
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsSetCard(0x107) and tc:IsType(TYPE_FIELD) then
		tc:RegisterFlagEffect(69553552,RESET_EVENT+RESETS_STANDARD,0,0)
		-- 获取因该卡效果除外的所有「方程式运动员」场地魔法。
		local wg=Duel.GetMatchingGroup(c69553552.winfilter,tp,LOCATION_REMOVED,0,nil)
		if wg:GetClassCount(Card.GetCode)==3 then
			local WIN_REASON_FA_WINNERS=0x1d
			-- 宣告当前玩家因「方程式运动员胜利团队」的效果决斗胜利。
			Duel.Win(tp,WIN_REASON_FA_WINNERS)
		end
	end
end
-- 过滤条件：带有本卡效果标记的除外状态的「方程式运动员」场地魔法。
function c69553552.winfilter(c)
	return c:IsSetCard(0x107) and c:IsType(TYPE_FIELD) and c:GetFlagEffect(69553552)~=0
end

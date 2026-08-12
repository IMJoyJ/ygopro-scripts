--妖竜マハーマ
-- 效果：
-- ①：对方回合，自己或者对方受到战斗伤害时才能发动。这张卡从手卡特殊召唤。那之后，从以下效果选1个适用。
-- ●自己基本分回复那次战斗伤害的数值。
-- ●给与对方那次战斗伤害数值的伤害。
function c545781.initial_effect(c)
	-- ①：对方回合，自己或者对方受到战斗伤害时才能发动。这张卡从手卡特殊召唤。那之后，从以下效果选1个适用。●自己基本分回复那次战斗伤害的数值。●给与对方那次战斗伤害数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(545781,0))  --"回复基本分"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c545781.sumcon)
	e1:SetTarget(c545781.sumtg)
	e1:SetOperation(c545781.sumop)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件：当前回合是对方回合
function c545781.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方玩家
	return Duel.GetTurnPlayer()==1-tp
end
-- 定义效果的发动检测：检查自身是否可以特殊召唤
function c545781.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：特殊召唤手卡中的这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义效果的处理：特殊召唤自身，并选择适用回复生命值或给与伤害的效果
function c545781.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡在自己场上表侧表示特殊召唤，若特殊召唤成功则继续处理后续效果
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 中断效果处理，使后续效果与特殊召唤不视为同时进行（会造成错时点）
		Duel.BreakEffect()
		-- 向玩家发送提示信息，要求选择要适用的效果
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
		-- 让玩家选择适用“回复基本分”或“给与伤害”中的一个效果
		local opt=Duel.SelectOption(tp,aux.Stringid(545781,0),aux.Stringid(545781,1))  --"回复基本分/给与伤害"
		if opt==0 then
			-- 使自己回复与那次战斗伤害相同数值的生命值
			Duel.Recover(tp,ev,REASON_EFFECT)
		else
			-- 给与对方与那次战斗伤害相同数值的伤害
			Duel.Damage(1-tp,ev,REASON_EFFECT)
		end
	end
end

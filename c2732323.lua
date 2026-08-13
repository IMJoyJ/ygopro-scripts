--デコイドラゴン
-- 效果：
-- ①：这张卡被选择作为攻击对象的场合，以自己墓地1只7星以上的龙族怪兽为对象发动。那只怪兽特殊召唤，攻击对象转移为那只怪兽进行伤害计算。
function c2732323.initial_effect(c)
	-- ①：这张卡被选择作为攻击对象的场合，以自己墓地1只7星以上的龙族怪兽为对象发动。那只怪兽特殊召唤，攻击对象转移为那只怪兽进行伤害计算。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2732323,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c2732323.sptg)
	e1:SetOperation(c2732323.spop)
	c:RegisterEffect(e1)
end
-- 筛选满足等级7以上、龙族且可以被特殊召唤的墓地怪兽作为效果对象候补。
function c2732323.spfilter(c,e,tp)
	return c:IsLevelAbove(7) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择处理：从自己墓地选择1只7星以上龙族怪兽作为对象，并设置特殊召唤的操作信息。
function c2732323.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c2732323.spfilter(chkc,e,tp) end
	if chk==0 then return true end
	-- 给当前玩家弹出选择提示，要求选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的7星以上龙族怪兽，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c2732323.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次连锁的处理信息，注明包含特殊召唤效果，处理对象为选中的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时：将对象怪兽特殊召唤，若成功则强制攻击怪兽对其再攻击并进行伤害计算。
function c2732323.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 暂时关闭因特殊召唤引起的自爆检查，避免召唤成功前发生意外破坏。
		Duel.DisableSelfDestroyCheck()
		-- 将对象怪兽表侧表示特殊召唤到己方场上，并判断是否召唤成功。
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
			-- 获取当前攻击宣言的怪兽（即原攻击者）。
			local a=Duel.GetAttacker()
			if a:IsAttackable() and not a:IsImmuneToEffect(e) then
				-- 让原攻击怪兽与特殊召唤出的怪兽进行战斗伤害计算，实现攻击对象转移。
				Duel.CalculateDamage(a,tc)
			end
		end
		-- 重新启用自爆检查（恢复默认规则）。
		Duel.DisableSelfDestroyCheck(false)
	end
end

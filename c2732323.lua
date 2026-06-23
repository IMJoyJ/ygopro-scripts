--デコイドラゴン
-- 效果：
-- ①：这张卡被选择作为攻击对象的场合，以自己墓地1只7星以上的龙族怪兽为对象发动。那只怪兽特殊召唤，攻击对象转移为那只怪兽进行伤害计算。
function c2732323.initial_effect(c)
	-- 诱发必发效果，当此卡被选为攻击对象时发动
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
-- 检索满足条件的墓地龙族7星以上怪兽
function c2732323.spfilter(c,e,tp)
	return c:IsLevelAbove(7) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 选择1只满足条件的墓地怪兽进行特殊召唤
function c2732323.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c2732323.spfilter(chkc,e,tp) end
	if chk==0 then return true end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从玩家墓地选择1只符合条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c2732323.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 将选中的怪兽特殊召唤到场上，并进行伤害计算
function c2732323.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 关闭卡片自爆检查以防止特殊召唤时自爆
		Duel.DisableSelfDestroyCheck()
		-- 将目标怪兽特殊召唤到场上
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
			-- 获取当前攻击的怪兽
			local a=Duel.GetAttacker()
			if a:IsAttackable() and not a:IsImmuneToEffect(e) then
				-- 令攻击怪兽与特殊召唤的怪兽进行伤害计算
				Duel.CalculateDamage(a,tc)
			end
		end
		-- 重新启用卡片自爆检查
		Duel.DisableSelfDestroyCheck(false)
	end
end

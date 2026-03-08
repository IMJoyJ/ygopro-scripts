--スパウン・アリゲーター
-- 效果：
-- 把爬虫类族怪兽解放对这张卡的上级召唤成功的场合，把1只为这张卡的上级召唤而解放的怪兽在那个回合的结束阶段时从墓地往自己场上特殊召唤。
function c39984786.initial_effect(c)
	-- 效果原文内容：把爬虫类族怪兽解放对这张卡的上级召唤成功的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c39984786.valcheck)
	c:RegisterEffect(e1)
end
-- 规则层面操作：检查上级召唤时是否使用了爬虫类族怪兽作为素材，若使用则为该怪兽标记flag，并注册结束阶段特殊召唤效果
function c39984786.valcheck(e,c)
	local g=c:GetMaterial()
	local tc=g:GetFirst()
	local sp=false
	while tc do
		if tc:IsRace(RACE_REPTILE) then
			tc:RegisterFlagEffect(39984786,RESET_EVENT+0x17a0000+RESET_PHASE+PHASE_END,0,1)
			sp=true
		end
		tc=g:GetNext()
	end
	if sp then
		-- 效果原文内容：把1只为这张卡的上级召唤而解放的怪兽在那个回合的结束阶段时从墓地往自己场上特殊召唤
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(39984786,0))  --"特殊召唤"
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1)
		e1:SetTarget(c39984786.sptg)
		e1:SetOperation(c39984786.spop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TURN_SET+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 规则层面操作：判断目标怪兽是否为上级召唤时使用的爬虫类族怪兽且可特殊召唤
function c39984786.filter(c,e,tp)
	return c:GetFlagEffect(39984786)~=0 and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_GRAVE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面操作：选择并设置要特殊召唤的爬虫类族怪兽作为目标
function c39984786.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return e:GetHandler():GetMaterial():IsContains(chkc) and c39984786.filter(chkc,e,tp) end
	if chk==0 then return true end
	-- 规则层面操作：向玩家提示“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local mg=e:GetHandler():GetMaterial()
	local g=mg:FilterSelect(tp,c39984786.filter,1,1,nil,e,tp)
	-- 规则层面操作：将选中的怪兽设置为效果处理的目标
	Duel.SetTargetCard(g)
	-- 规则层面操作：设置本次连锁的操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 规则层面操作：执行特殊召唤处理，将符合条件的怪兽从墓地特殊召唤到场上
function c39984786.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前效果处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 规则层面操作：将目标怪兽以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

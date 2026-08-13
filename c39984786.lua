--スパウン・アリゲーター
-- 效果：
-- 把爬虫类族怪兽解放对这张卡的上级召唤成功的场合，把1只为这张卡的上级召唤而解放的怪兽在那个回合的结束阶段时从墓地往自己场上特殊召唤。
function c39984786.initial_effect(c)
	-- 把爬虫类族怪兽解放对这张卡的上级召唤成功的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c39984786.valcheck)
	c:RegisterEffect(e1)
end
-- 检查上级召唤使用的素材，若素材中有爬虫类族怪兽，则给这些素材标记flag并持续到结束阶段，同时为本卡注册在结束阶段发动的特殊召唤效果
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
		-- 把1只为这张卡的上级召唤而解放的怪兽在那个回合的结束阶段时从墓地往自己场上特殊召唤。
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
-- 筛选满足条件的对象：拥有解放标记的爬虫类素材、能成为效果对象、在墓地且可以被特殊召唤
function c39984786.filter(c,e,tp)
	return c:GetFlagEffect(39984786)~=0 and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_GRAVE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时从这张卡的解放素材中选择1只符合条件的爬虫类怪兽作为对象，并设置特殊召唤的操作信息
function c39984786.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return e:GetHandler():GetMaterial():IsContains(chkc) and c39984786.filter(chkc,e,tp) end
	if chk==0 then return true end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local mg=e:GetHandler():GetMaterial()
	local g=mg:FilterSelect(tp,c39984786.filter,1,1,nil,e,tp)
	-- 将选择的卡设置为当前连锁的效果对象
	Duel.SetTargetCard(g)
	-- 设置本次效果处理的信息：将1只对象怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时，若对象仍与效果关联，则将其特殊召唤
function c39984786.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时的对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

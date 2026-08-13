--銀河騎士
-- 效果：
-- ①：自己场上有「光子」怪兽或者「银河」怪兽存在的场合，这张卡可以不用解放作召唤。
-- ②：这张卡的①的方法召唤成功的场合，以自己墓地1只「银河眼光子龙」为对象发动。这张卡的攻击力直到回合结束时下降1000，作为对象的怪兽守备表示特殊召唤。
function c35950025.initial_effect(c)
	-- ①：自己场上有「光子」怪兽或者「银河」怪兽存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35950025,0))  --"不用解放作召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c35950025.ntcon)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的方法召唤成功的场合，以自己墓地1只「银河眼光子龙」为对象发动。这张卡的攻击力直到回合结束时下降1000，作为对象的怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35950025,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c35950025.spcon)
	e2:SetTarget(c35950025.sptg)
	e2:SetOperation(c35950025.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查怪兽是否为表侧表示且持有「光子」或「银河」字段，用于判断自己场上是否存在满足①条件的怪兽。
function c35950025.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x55,0x7b)
end
-- ①的无解放召唤规则效果的条件：当这张卡可以不用解放作通常召唤（即不进行解放、且等级为5以上、自己主要怪兽区有空位），并且自己场上有表侧表示的「光子」或「银河」怪兽时，召唤规则效果适用。
function c35950025.ntcon(e,c,minc)
	if c==nil then return true end
	-- 召唤条件判断：必须是不解放召唤（minc==0）、这张卡等级为5以上、自己场上有可用的主要怪兽区空格。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 同时自己场上存在至少1张表侧表示的「光子」或「银河」怪兽（满足cfilter的卡）。
		and Duel.IsExistingMatchingCard(c35950025.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- ②的诱发条件：这张卡是通过①的方法（无解放通常召唤）召唤成功的场合。
function c35950025.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_NORMAL+SUMMON_VALUE_SELF
end
-- 过滤函数：选择自己墓地的「银河眼光子龙」作为对象，并且确认它可以被特殊召唤为表侧守备表示。
function c35950025.spfilter(c,e,tp)
	return c:IsCode(93717133) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②的发动时的目标选择处理：从自己墓地选择1只「银河眼光子龙」作为效果对象，并登记特殊召唤的操作信息。
function c35950025.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c35950025.spfilter(chkc,e,tp) end
	if chk==0 then return true end
	-- 向玩家显示提示消息，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足spfilter的「银河眼光子龙」作为效果对象。
	local g=Duel.SelectTarget(tp,c35950025.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记本次连锁将进行特殊召唤的操作信息，供其他卡效果（如星尘龙）进行发动判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②的效果处理：这张卡仍表侧表示且与效果关联时，使其攻击力下降1000，并将对象怪兽特殊召唤到场上（表侧守备表示）。
function c35950025.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时下降1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 取得发动时选择的对象怪兽（自己墓地的「银河眼光子龙」）。
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			-- 将对象怪兽以表侧守备表示特殊召唤到自己的场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end

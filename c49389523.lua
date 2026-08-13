--ライトニング・トライコーン
-- 效果：
-- 调整＋调整以外的兽族怪兽1只以上
-- 这张卡被对方破坏的场合，可以选择自己墓地存在的1只「雷电独角兽」或者「流电双角兽」在自己场上特殊召唤。
function c49389523.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的兽族怪兽1只以上（调整无限制，非调整必须为兽族）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_BEAST),1)
	c:EnableReviveLimit()
	-- 这张卡被对方破坏的场合，可以选择自己墓地存在的1只「雷电独角兽」或者「流电双角兽」在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49389523,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c49389523.spcon)
	e1:SetTarget(c49389523.sptg)
	e1:SetOperation(c49389523.spop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：这张卡被对方破坏（rp为对方），且被破坏前这张卡的控制者是我方（tp）。
function c49389523.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 筛选墓地中的对象：卡名必须是「雷电独角兽」或「流电双角兽」，并且能够被当前效果特殊召唤。
function c49389523.filter(c,e,tp)
	return c:IsCode(77506119,13995824) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时目标选择处理：先验证选择的对象合法（chkc），再检查合法性（chk==0）时需满足我方主怪兽区有空位且墓地存在至少1张符合条件的卡。
function c49389523.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c49389523.filter(chkc,e,tp) end
	-- 发动合法性检查：我方场上有可用的主怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动合法性检查：墓地存在至少1张满足过滤条件的卡可以作为效果对象。
		and Duel.IsExistingTarget(c49389523.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示特殊召唤对象选择的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从我方墓地选择1张符合条件的卡作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,c49389523.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，声明本次连锁将进行1只怪兽的特殊召唤，供其他卡判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时：取得对象，若对象仍与效果关联（未离开墓地），则将其特殊召唤到我方场上。
function c49389523.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时的对象卡（此前选择的雷电独角兽或流电双角兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象以表侧表示特殊召唤到我方场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

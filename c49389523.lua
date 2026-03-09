--ライトニング・トライコーン
-- 效果：
-- 调整＋调整以外的兽族怪兽1只以上
-- 这张卡被对方破坏的场合，可以选择自己墓地存在的1只「雷电独角兽」或者「流电双角兽」在自己场上特殊召唤。
function c49389523.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求1只调整和1只调整以外的兽族怪兽作为素材
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
-- 效果发动条件：破坏时的控制权变更且为对方破坏
function c49389523.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 过滤满足条件的卡片：卡号为雷电独角兽或流电双角兽，并且可以被特殊召唤
function c49389523.filter(c,e,tp)
	return c:IsCode(77506119,13995824) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的目标选择函数，用于选择墓地中的符合条件的卡片
function c49389523.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c49389523.filter(chkc,e,tp) end
	-- 判断是否满足发动条件：场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足发动条件：墓地中是否存在符合条件的卡片
		and Duel.IsExistingTarget(c49389523.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标卡片并设置为效果对象
	local g=Duel.SelectTarget(tp,c49389523.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁的操作信息，确定将要特殊召唤的卡片数量和类型
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：将选中的卡片特殊召唤到场上
function c49389523.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片以正面表示的形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

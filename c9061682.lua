--魔轟神アンドレイス
-- 效果：
-- 「魔轰神」调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。对方可以选1张手卡丢弃让这个效果无效。没丢弃的场合，自己抽2张。抽卡的场合，再选自己1张手卡丢弃。
-- ②：怪兽从对方手卡送去墓地的场合，以那之内的1只为对象才能发动。那只怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c9061682.initial_effect(c)
	-- 添加同调召唤手续：以「魔轰神」调整加调整以外的怪兽1只以上为素材
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x35),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。对方可以选1张手卡丢弃让这个效果无效。没丢弃的场合，自己抽2张。抽卡的场合，再选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9061682,0))  --"抽卡并丢弃手卡"
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,9061682)
	e1:SetTarget(c9061682.target)
	e1:SetOperation(c9061682.operation)
	c:RegisterEffect(e1)
	-- ②：怪兽从对方手卡送去墓地的场合，以那之内的1只为对象才能发动。那只怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9061682,2))  --"特殊召唤对方的怪兽"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,9061683)
	e2:SetTarget(c9061682.sptg)
	e2:SetOperation(c9061682.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动准备与检测函数
function c9061682.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身是否可以从卡组抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置连锁信息：包含抽卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	-- 设置连锁信息：包含丢弃手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 效果①的处理函数：处理对方是否丢弃手卡使效果无效，以及后续的抽卡和丢弃手卡处理
function c9061682.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方手卡是否大于0张，且当前连锁效果是否可以被无效
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 and Duel.IsChainDisablable(0)
		-- 询问对方是否选择丢弃1张手卡来使这个效果无效
		and Duel.SelectYesNo(1-tp,aux.Stringid(9061682,1)) then  --"是否丢弃手卡让「魔轰神 安德剌斯」的效果无效？"
		-- 对方选择并丢弃1张手卡
		Duel.DiscardHand(1-tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
		-- 使当前连锁的效果无效
		Duel.NegateEffect(0)
		return
	end
	-- 若对方未丢弃手卡，则自己抽2张卡，并检查是否成功抽到了2张
	if Duel.Draw(tp,2,REASON_EFFECT)==2 then
		-- 洗切自己的手卡
		Duel.ShuffleHand(tp)
		-- 中断当前效果处理，使后续的丢弃手卡处理与抽卡不视为同时进行
		Duel.BreakEffect()
		-- 自己选择并丢弃1张手卡
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 过滤条件：可以被特殊召唤、原本在对方手卡、且属于本次送去墓地卡片组中的怪兽
function c9061682.filter(c,e,tp,g)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsPreviousLocation(LOCATION_HAND) and c:IsPreviousControler(1-tp) and g:IsContains(c)
end
-- 效果②的发动准备与取对象检测函数
function c9061682.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c9061682.filter(chkc,e,tp,eg) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在满足条件的、可作为效果对象的怪兽
		and Duel.IsExistingTarget(c9061682.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,eg) end
	-- 给发动效果的玩家发送提示信息：“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c9061682.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp,eg)
	-- 设置连锁信息：包含特殊召唤所选对象怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的处理函数：将作为对象的怪兽在自己场上特殊召唤，并将其效果无效化
function c9061682.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽以及这张卡自身
	local tc,c=Duel.GetFirstTarget(),e:GetHandler()
	-- 若对象怪兽仍与效果相关，则将其以表侧表示在自己场上特殊召唤（分步处理）
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤的最终处理
	Duel.SpecialSummonComplete()
end

--ドシン＠イグニスター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「@火灵天星」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：以自己墓地1只电子界族连接怪兽为对象才能发动。那只怪兽回到额外卡组，从卡组把1张「“艾”慕融合」加入手卡。
function c78751195.initial_effect(c)
	-- ①：自己场上有「@火灵天星」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78751195,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,78751195)
	e1:SetCondition(c78751195.spcon)
	e1:SetTarget(c78751195.sptg)
	e1:SetOperation(c78751195.spop)
	c:RegisterEffect(e1)
	-- ②：以自己墓地1只电子界族连接怪兽为对象才能发动。那只怪兽回到额外卡组，从卡组把1张「“艾”慕融合」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78751195,1))
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,78751196)
	e2:SetTarget(c78751195.tetg)
	e2:SetOperation(c78751195.teop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「@火灵天星」怪兽
function c78751195.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x135)
end
-- 特殊召唤效果的发动条件：自己场上存在「@火灵天星」怪兽
function c78751195.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「@火灵天星」怪兽
	return Duel.IsExistingMatchingCard(c78751195.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果的发动准备与检测
function c78751195.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理
function c78751195.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：自己墓地的电子界族连接怪兽，且能回到额外卡组
function c78751195.tefilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_LINK) and c:IsAbleToExtra()
end
-- 过滤条件：卡组中的「“艾”慕融合」且能加入手卡
function c78751195.thfilter(c)
	return c:IsCode(59332125) and c:IsAbleToHand()
end
-- 回额外卡组并检索效果的发动准备与检测
function c78751195.tetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c78751195.tefilter(chkc) end
	-- 检查自己墓地是否存在满足条件的电子界族连接怪兽
	if chk==0 then return Duel.IsExistingTarget(c78751195.tefilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 并且检查卡组中是否存在可以加入手卡的「“艾”慕融合」
		and Duel.IsExistingMatchingCard(c78751195.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1只电子界族连接怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c78751195.tefilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选中的怪兽送回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 回额外卡组并检索效果的处理
function c78751195.teop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍符合效果，则将其送回额外卡组，并确认其已成功回到额外卡组
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA) then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张「“艾”慕融合」
		local g=Duel.SelectMatchingCard(tp,c78751195.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的卡加入手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end

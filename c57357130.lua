--転生炎獣ウィーゼル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己墓地的「转生炎兽」怪兽是2只以上的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡在墓地存在的状态，自己场上有「转生炎兽」仪式·融合·同调·超量·连接怪兽特殊召唤的场合，以这张卡以外的自己墓地1只「转生炎兽」怪兽为对象才能发动。这张卡回到卡组最下面，作为对象的怪兽在对方场上特殊召唤。那之后，自己抽1张。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含效果①和效果②的注册
function s.initial_effect(c)
	-- 注册一个用于检测此卡是否已在墓地的状态检查效果，用于后续墓地诱发效果的合法性验证
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ①：自己墓地的「转生炎兽」怪兽是2只以上的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上有「转生炎兽」仪式·融合·同调·超量·连接怪兽特殊召唤的场合，以这张卡以外的自己墓地1只「转生炎兽」怪兽为对象才能发动。这张卡回到卡组最下面，作为对象的怪兽在对方场上特殊召唤。那之后，自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetLabelObject(e0)
	e2:SetCondition(s.spdcon)
	e2:SetTarget(s.spdtg)
	e2:SetOperation(s.spdpop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地的「转生炎兽」怪兽
function s.spfilter(c)
	return c:IsSetCard(0x119) and c:IsType(TYPE_MONSTER)
end
-- 效果①的发动条件：自己墓地存在2只以上的「转生炎兽」怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在至少2张满足过滤条件的「转生炎兽」怪兽
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,2,nil)
end
-- 效果①的发动准备（Target）：检查自身是否能特殊召唤以及怪兽区域是否有空位
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理（Operation）：将手牌中的这张卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：自己场上表侧表示特殊召唤的「转生炎兽」仪式·融合·同调·超量·连接怪兽（且排除由该效果自身引起的特殊召唤）
function s.cfilter(c,tp,se)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x119) and c:IsType(TYPE_FUSION+TYPE_RITUAL+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
		and (se==nil or c:GetReasonEffect()~=se)
end
-- 效果②的发动条件：自己场上有「转生炎兽」仪式·融合·同调·超量·连接怪兽特殊召唤
function s.spdcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,nil,tp,se)
end
-- 过滤条件：自己墓地中可以特殊召唤到对方场上的「转生炎兽」怪兽
function s.spdfilter(c,e,tp)
	return c:IsSetCard(0x119) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- 效果②的发动准备（Target）：选择自己墓地1只「转生炎兽」怪兽为对象，并确认自己是否能抽卡以及对方场上是否有空位
function s.spdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spdfilter(chkc,e,tp) and chkc~=c end
	-- 检查自己当前是否可以进行抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查对方场上是否有可用于特殊召唤的怪兽区域空位
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		-- 检查自己墓地是否存在除自身以外、可以特殊召唤到对方场上的「转生炎兽」怪兽
		and Duel.IsExistingTarget(s.spdfilter,tp,LOCATION_GRAVE,0,1,c,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「转生炎兽」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,s.spdfilter,tp,LOCATION_GRAVE,0,1,1,c,e,tp)
	-- 设置连锁处理中的操作信息：将自身回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
	-- 设置连锁处理中的操作信息：特殊召唤作为对象的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置连锁处理中的操作信息：自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②的效果处理（Operation）：自身回到卡组最下面，将对象怪兽在对方场上特殊召唤，那之后自己抽1张
function s.spdpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的作为特殊召唤对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查自身是否仍与效果相关，并将其回到持有者卡组最下面
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_DECK)
		-- 检查对象怪兽是否仍与效果相关，且对方场上仍有可用的怪兽区域空位
		and tc:IsRelateToEffect(e) and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		-- 将作为对象的怪兽以表侧表示特殊召唤到对方场上
		and Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP)>0
		-- 检查自己是否仍能进行抽卡
		and Duel.IsPlayerCanDraw(tp) then
		-- 中断当前效果处理，使后续的抽卡处理不与特殊召唤同时进行（用于处理“那之后”的时点）
		Duel.BreakEffect()
		-- 让自己从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

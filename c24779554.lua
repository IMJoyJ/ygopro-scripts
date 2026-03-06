--白き森のルシア
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己场上有「白森林」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：从自己的手卡·场上把1张魔法·陷阱卡送去墓地才能发动。自己抽1张。
-- ③：自己·对方回合，这张卡在墓地存在的场合，以自己的场上·墓地1只「白森林」同调怪兽为对象才能发动。那只怪兽回到额外卡组，这张卡效果无效特殊召唤。
local s,id,o=GetID()
-- 创建三个效果，分别对应①②③效果的发动条件和处理
function s.initial_effect(c)
	-- ①：自己场上有「白森林」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：从自己的手卡·场上把1张魔法·陷阱卡送去墓地才能发动。自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.drcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	-- ③：自己·对方回合，这张卡在墓地存在的场合，以自己的场上·墓地1只「白森林」同调怪兽为对象才能发动。那只怪兽回到额外卡组，这张卡效果无效特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"墓地特殊召唤"
	e3:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在「白森林」怪兽
function s.cfilter(c)
	return c:IsSetCard(0x1b1) and c:IsFaceup()
end
-- 判断是否满足①效果的发动条件：自己场上有「白森林」怪兽存在
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足①效果的发动条件：自己场上有「白森林」怪兽存在
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动时点处理，判断是否满足特殊召唤的条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足①效果的发动条件：场上存在空位且此卡可特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置①效果的处理信息，将此卡设为特殊召唤对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的发动处理，将此卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于判断手牌或场上的魔法·陷阱卡
function s.drfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- ②效果的发动时点处理，选择并送入墓地的魔法·陷阱卡
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足②效果的发动条件：手牌或场上存在魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.drfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择要送去墓地的魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.drfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的卡送去墓地作为②效果的费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②效果的发动时点处理，判断是否可以抽卡
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足②效果的发动条件：玩家可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置②效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置②效果的目标参数为抽卡数量1
	Duel.SetTargetParam(1)
	-- 设置②效果的处理信息，将抽卡设为处理对象
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果的发动处理，执行抽卡操作
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 过滤函数，用于判断是否为「白森林」同调怪兽且可返回额外卡组
function s.spfilter2(c,tp)
	-- 判断是否为「白森林」同调怪兽且可返回额外卡组
	return Duel.GetMZoneCount(tp,c)>0 and c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
		and c:IsAbleToExtra() and c:IsSetCard(0x1b1)
end
-- ③效果的发动时点处理，选择目标怪兽并判断是否满足特殊召唤条件
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter2(chkc,tp) end
	-- 判断是否满足③效果的发动条件：场上或墓地存在「白森林」同调怪兽
	if chk==0 then return Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	-- 提示玩家选择要返回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择要返回卡组的「白森林」同调怪兽
	local g=Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置③效果的处理信息，将目标怪兽设为返回卡组对象
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,#g,0,0)
	-- 设置③效果的处理信息，将此卡设为特殊召唤对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ③效果的发动处理，将目标怪兽返回额外卡组并特殊召唤此卡
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取③效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且已返回额外卡组
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_EXTRA)
		-- 判断是否满足③效果的发动条件：场上存在空位且此卡可特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 使此卡获得无效化效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		c:RegisterEffect(e1)
		-- 使此卡获得无效化效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
	-- 完成特殊召唤操作
	Duel.SpecialSummonComplete()
end

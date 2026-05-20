--ジャンク・マイスター
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把额外卡组1只「战士」、「星尘」同调怪兽给对方观看才能发动。这张卡从手卡特殊召唤。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把「废品大王」以外的1张「废品」卡加入手卡。
-- ③：以自己场上1只「废品」怪兽为对象才能发动。那只怪兽的等级下降最多2星。
local s,id,o=GetID()
-- 注册卡片效果（①手卡特召及额外特召限制，②召唤·特召成功检索「废品」卡，③以场上「废品」怪兽为对象降星）
function s.initial_effect(c)
	-- ①：把额外卡组1只「战士」、「星尘」同调怪兽给对方观看才能发动。这张卡从手卡特殊召唤。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把「废品大王」以外的1张「废品」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：以自己场上1只「废品」怪兽为对象才能发动。那只怪兽的等级下降最多2星。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"改变等级"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,id+o*2)
	e4:SetTarget(s.lvtg)
	e4:SetOperation(s.lvop)
	c:RegisterEffect(e4)
end
-- 过滤条件：额外卡组中未给对方确认的「战士」或「星尘」同调怪兽
function s.cfilter(c)
	return c:IsSetCard(0x66,0xa3) and c:IsAllTypes(TYPE_SYNCHRO+TYPE_MONSTER) and not c:IsPublic()
end
-- 效果①的发动代价：把额外卡组1只满足条件的同调怪兽给对方观看
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在可以给对方确认的「战士」或「星尘」同调怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家选择额外卡组1只满足条件的同调怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 给对方玩家确认选择的卡
	Duel.ConfirmCards(1-tp,g)
end
-- 效果①的发动准备：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理：将自身特殊召唤，并适用“这个回合自己不是同调怪兽不能从额外卡组特殊召唤”的限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。②：这张卡召唤·特殊召唤的场合才能发动。从卡组把「废品大王」以外的1张「废品」卡加入手卡。③：以自己场上1只「废品」怪兽为对象才能发动。那只怪兽的等级下降最多2星。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册额外卡组特殊召唤限制的玩家效果
	Duel.RegisterEffect(e2,tp)
end
-- 限制只能从额外卡组特殊召唤同调怪兽
function s.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤条件：卡组中「废品大王」以外且可以加入手牌的「废品」卡
function s.thfilter(c)
	return c:IsSetCard(0x43) and not c:IsCode(id) and c:IsAbleToHand()
end
-- 效果②的发动准备：检查卡组是否存在满足条件的「废品」卡，并设置检索的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在「废品大王」以外的「废品」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置从卡组将1张卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理：从卡组选择1张「废品大王」以外的「废品」卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择卡组中1张满足条件的「废品」卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：自己场上表侧表示、等级在2星以上且可以降星的「废品」怪兽
function s.lvfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x43) and c:IsLevelAbove(2)
end
-- 效果③的发动准备：选择自己场上1只表侧表示的「废品」怪兽作为对象
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.lvfilter(chkc) end
	-- 检查自己场上是否存在可以作为对象的「废品」怪兽
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择1只表侧表示的「废品」怪兽作为效果对象
	Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果③的处理：让作为对象的怪兽等级下降最多2星
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToChain() then
		local t={}
		for i=1,2 do
			if tc:GetLevel()-i>0 then table.insert(t,i) end
		end
		if #t==0 then return end
		-- 玩家选择要下降的等级数值（1或2）
		local lv=Duel.AnnounceNumber(tp,table.unpack(t))
		-- 那只怪兽的等级下降最多2星。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-lv)
		tc:RegisterEffect(e1)
	end
end

--アカシック・マジシャン
-- 效果：
-- 衍生物以外的相同种族的怪兽2只
-- 自己对「虚空俏丽魔术师」1回合只能有1次连接召唤。
-- ①：这张卡连接召唤成功的场合发动。这张卡所连接区的怪兽全部回到持有者手卡。
-- ②：1回合1次，宣言1个卡名才能发动。把这张卡所互相连接区的怪兽的连接标记合计数量的卡从自己卡组上面翻开，那之中有宣言的卡的场合，那卡加入手卡。那以外的翻开的卡全部送去墓地。
function c28776350.initial_effect(c)
	-- 添加连接召唤手续，要求连接素材为非衍生物且种族相同的怪兽，最少2个，最多2个
	aux.AddLinkProcedure(c,aux.NOT(aux.FilterBoolFunction(Card.IsLinkType,TYPE_TOKEN)),2,2,c28776350.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤成功的场合发动。这张卡所连接区的怪兽全部回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c28776350.regcon)
	e1:SetOperation(c28776350.regop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，宣言1个卡名才能发动。把这张卡所互相连接区的怪兽的连接标记合计数量的卡从自己卡组上面翻开，那之中有宣言的卡的场合，那卡加入手卡。那以外的翻开的卡全部送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28776350,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c28776350.thcon)
	e2:SetTarget(c28776350.thtg)
	e2:SetOperation(c28776350.thop)
	c:RegisterEffect(e2)
	-- 自己对「虚空俏丽魔术师」1回合只能有1次连接召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(28776350,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c28776350.actg)
	e3:SetOperation(c28776350.acop)
	c:RegisterEffect(e3)
end
-- 连接召唤时检查连接怪兽的种族是否一致
function c28776350.lcheck(g)
	-- 检查连接怪兽的种族是否一致
	return aux.SameValueCheck(g,Card.GetLinkRace)
end
-- 判断是否为连接召唤
function c28776350.regcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
-- 设置效果，使自己不能特殊召唤「虚空俏丽魔术师」
function c28776350.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置效果，使自己不能特殊召唤「虚空俏丽魔术师」
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(c28776350.splimit)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制自己不能特殊召唤「虚空俏丽魔术师」
function c28776350.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(28776350) and bit.band(sumtype,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
-- 判断是否为连接召唤
function c28776350.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 设置连锁操作信息，准备将连接区怪兽送回手牌
function c28776350.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local lg=e:GetHandler():GetLinkedGroup():Filter(Card.IsAbleToHand,nil)
	-- 设置连锁操作信息，准备将连接区怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,lg,lg:GetCount(),0,0)
end
-- 将连接区怪兽送回手牌
function c28776350.thop(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup():Filter(Card.IsAbleToHand,nil)
	-- 将连接区怪兽送回手牌
	Duel.SendtoHand(lg,nil,REASON_EFFECT)
end
-- 设置发动条件，检查是否可以翻开卡组顶部的卡并有能加入手牌的卡
function c28776350.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local lg=c:GetMutualLinkedGroup()
		local ct=lg:GetSum(Card.GetLink)
		-- 检查是否可以翻开卡组顶部的卡
		if ct<=0 or not Duel.IsPlayerCanDiscardDeck(tp,ct) then return false end
		-- 获取卡组顶部的卡
		local g=Duel.GetDecktopGroup(tp,ct)
		return g:FilterCount(Card.IsAbleToHand,nil)>0
	end
	-- 提示玩家选择卡名
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	getmetatable(e:GetHandler()).announce_filter={TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT}
	-- 让玩家宣言一个卡名
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 设置连锁目标参数为宣言的卡名
	Duel.SetTargetParam(ac)
	-- 设置连锁操作信息，准备处理宣言的卡名
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 过滤满足条件的卡
function c28776350.thfilter(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
-- 处理效果，翻开卡组顶部的卡并处理结果
function c28776350.acop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lg=c:GetMutualLinkedGroup()
	local ct=lg:GetSum(Card.GetLink)
	-- 检查是否可以翻开卡组顶部的卡
	if ct<=0 or not Duel.IsPlayerCanDiscardDeck(tp,ct) then return end
	-- 确认卡组顶部的卡
	Duel.ConfirmDecktop(tp,ct)
	-- 获取卡组顶部的卡
	local g=Duel.GetDecktopGroup(tp,ct)
	-- 获取连锁目标参数
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local hg=g:Filter(c28776350.thfilter,nil,ac)
	g:Sub(hg)
	if hg:GetCount()~=0 then
		-- 禁止洗切卡组
		Duel.DisableShuffleCheck()
		-- 将符合条件的卡加入手牌
		Duel.SendtoHand(hg,nil,REASON_EFFECT)
		-- 确认对方查看卡牌
		Duel.ConfirmCards(1-tp,hg)
		-- 洗切手牌
		Duel.ShuffleHand(tp)
	end
	if g:GetCount()~=0 then
		-- 禁止洗切卡组
		Duel.DisableShuffleCheck()
		-- 将不符合条件的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
	end
end

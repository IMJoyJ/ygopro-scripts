--LL－セレスト・ワグテイル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。从卡组把1张「抒情歌鸲」魔法·陷阱卡加入手卡。
-- ②：这张卡在墓地存在的场合，以自己场上1只「抒情歌鸲」超量怪兽为对象才能发动。把这张卡在那只怪兽下面重叠作为超量素材。
function c46576366.initial_effect(c)
	-- ①：这张卡特殊召唤成功的场合才能发动。从卡组把1张「抒情歌鸲」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46576366,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,46576366)
	e1:SetTarget(c46576366.thtg)
	e1:SetOperation(c46576366.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己场上1只「抒情歌鸲」超量怪兽为对象才能发动。把这张卡在那只怪兽下面重叠作为超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46576366,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,46576367)
	e2:SetTarget(c46576366.ovtg)
	e2:SetOperation(c46576366.ovop)
	c:RegisterEffect(e2)
end
-- 检索满足条件的魔法·陷阱卡（属于抒情歌鸲系列且能加入手牌）
function c46576366.thfilter(c)
	return c:IsSetCard(0xf7) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置连锁处理时的操作信息，表示将从卡组检索1张魔法·陷阱卡加入手牌
function c46576366.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：卡组中是否存在至少1张满足条件的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c46576366.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，指定要处理的卡为卡组中的魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行检索并加入手牌的操作
function c46576366.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的1张魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c46576366.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数，筛选场上正面表示的抒情歌鸲系列超量怪兽
function c46576366.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf7) and c:IsType(TYPE_XYZ)
end
-- 设置效果目标选择函数，用于选择场上的抒情歌鸲超量怪兽
function c46576366.ovtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c46576366.ovfilter(chkc) end
	-- 检查是否满足发动条件：场上是否存在至少1只满足条件的超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c46576366.ovfilter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanOverlay() end
	-- 提示玩家选择效果的对象（场上的抒情歌鸲超量怪兽）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择目标怪兽作为效果对象
	Duel.SelectTarget(tp,c46576366.ovfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息，表示将把此卡从墓地叠放至怪兽下面
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果处理函数，执行将此卡叠放至目标怪兽下的操作
function c46576366.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中指定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsCanOverlay() and tc:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 将此卡叠放至目标怪兽下方作为超量素材
		Duel.Overlay(tc,Group.FromCards(c))
	end
end

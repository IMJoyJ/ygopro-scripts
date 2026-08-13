--LL－セレスト・ワグテイル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。从卡组把1张「抒情歌鸲」魔法·陷阱卡加入手卡。
-- ②：这张卡在墓地存在的场合，以自己场上1只「抒情歌鸲」超量怪兽为对象才能发动。把这张卡在那只怪兽下面重叠作为超量素材。
function c46576366.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡特殊召唤成功的场合才能发动。从卡组把1张「抒情歌鸲」魔法·陷阱卡加入手卡。
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
-- 过滤函数：筛选卡组中持有「抒情歌鸲」字段、种类为魔法·陷阱、且可以被加入手卡的卡。
function c46576366.thfilter(c)
	return c:IsSetCard(0xf7) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 发动条件与操作信息设定：当卡组中存在符合条件的「抒情歌鸲」魔法·陷阱卡时允许发动，并预设置将卡组中1张卡加入手卡的操作信息。
function c46576366.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 可发动性检查：确认卡组中是否存在至少1张满足thfilter条件的「抒情歌鸲」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c46576366.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果为将卡组中1张卡加入手卡，卡名未确定，数量1，作用位置为你的卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张符合条件的「抒情歌鸲」魔法·陷阱卡加入手卡，并向对方展示检索到的卡。
function c46576366.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要加入手牌的卡”的提示信息，以便进行检索选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让当前玩家从自己的卡组中选出1张满足thfilter的「抒情歌鸲」魔法·陷阱卡，作为本次检索加入手卡的对象。
	local g=Duel.SelectMatchingCard(tp,c46576366.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡，加入原因记为效果导致的移动。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索加入手卡的卡展示给对方玩家确认，保证检索内容公开合法。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：筛选自己场上表侧表示、持有「抒情歌鸲」字段、且为超量怪兽的卡。
function c46576366.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf7) and c:IsType(TYPE_XYZ)
end
-- 取对象发动判定与对象选择：选择自己场上1只符合条件的「抒情歌鸲」超量怪兽作为对象，并确认墓地的这张卡能够作为超量素材。
function c46576366.ovtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c46576366.ovfilter(chkc) end
	-- 可发动性检查：自己场上有符合条件的「抒情歌鸲」超量怪兽，且这张墓地的卡本身可以被叠放为超量素材。
	if chk==0 then return Duel.IsExistingTarget(c46576366.ovfilter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanOverlay() end
	-- 向玩家显示“请选择效果的对象”的提示信息，引导玩家选择超量怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只符合条件的「抒情歌鸲」超量怪兽，将其登记为当前连锁的对象（取对象效果）。
	Duel.SelectTarget(tp,c46576366.ovfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本效果会使墓地的这张卡离开墓地，作为超量素材叠放，供其他效果判定（如王家长眠之谷）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与效果关联、可作超量素材，且对象怪兽仍与效果关联且双方均不免疫此效果，则将这张卡叠放在对象怪兽下方。
function c46576366.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本效果发动时所选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsCanOverlay() and tc:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 将这张卡作为超量素材叠放在对象超量怪兽的下面。
		Duel.Overlay(tc,Group.FromCards(c))
	end
end

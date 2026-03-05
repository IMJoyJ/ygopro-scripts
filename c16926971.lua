--ファイアウォール・S・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合，以自己的墓地·除外状态的1只电子界族怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：以自己场上1只其他的电子界族怪兽为对象才能发动。这张卡的等级变成和那只怪兽相同。
-- ③：这张卡作为连接素材送去墓地的场合才能发动。从卡组把1张「“艾”」魔法卡加入手卡。
local s,id,o=GetID()
-- 初始化效果函数，设置同调召唤程序、启用复活限制并注册三个效果
function s.initial_effect(c)
	-- 为该卡添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合，以自己的墓地·除外状态的1只电子界族怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回收效果"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只其他的电子界族怪兽为对象才能发动。这张卡的等级变成和那只怪兽相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"改变等级"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
	-- ③：这张卡作为连接素材送去墓地的场合才能发动。从卡组把1张「“艾”」魔法卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.thcon2)
	e3:SetTarget(s.thtg2)
	e3:SetOperation(s.thop2)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：确认此卡是通过同调召唤方式特殊召唤成功
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果①中用于检索目标的过滤函数：满足条件的卡必须是表侧表示、电子界族、怪兽卡且能加入手牌
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_CYBERSE)
		and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的目标选择函数：选择满足条件的墓地或除外区的电子界族怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 效果①的目标选择检查：确认场上是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择目标卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地或除外区的电子界族怪兽作为目标
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息，表示将要将目标卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①的处理函数：将目标卡加入手牌并确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效且未受王家长眠之谷影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 效果②中用于选择目标的过滤函数：满足条件的卡必须是表侧表示、电子界族、等级不等于当前卡等级且等级大于等于1
function s.lvfilter(c,lv)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE) and not c:IsLevel(lv) and c:IsLevelAbove(1)
end
-- 效果②的目标选择函数：选择满足条件的己方场上电子界族怪兽
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.lvfilter(chkc,c:GetLevel()) and chkc~=c end
	-- 效果②的目标选择检查：确认场上是否存在满足条件的卡
	if chk==0 then return c:IsLevelAbove(1) and Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,c,c:GetLevel()) end
	-- 提示玩家选择目标卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的己方场上电子界族怪兽作为目标
	Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,c,c:GetLevel())
end
-- 效果②的处理函数：将此卡等级改为与目标卡等级相同
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		-- 设置等级改变效果，使此卡等级变为目标卡等级
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 效果③的发动条件：确认此卡是作为连接素材送去墓地
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK and e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 效果③中用于检索目标的过滤函数：满足条件的卡必须是“艾”系列魔法卡且能加入手牌
function s.thfilter2(c)
	return c:IsSetCard(0x136) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果③的目标选择函数：选择满足条件的卡组中的“艾”系列魔法卡
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果③的目标选择检查：确认卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将要将目标卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的处理函数：从卡组选择一张“艾”系列魔法卡加入手牌并确认
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择目标卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡组中的“艾”系列魔法卡作为目标
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将目标卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end

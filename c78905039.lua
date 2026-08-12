--響魔従トライコーン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己怪兽被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡从场上送去墓地的场合，以持有和自己场上的怪兽的其中任意种相同种族·属性的自己墓地1只怪兽为对象才能发动。那只怪兽加入手卡。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果：①手卡特召效果，②送墓回收效果，以及用于检测怪兽破坏的全局监听效果
function s.initial_effect(c)
	-- ①：自己怪兽被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合，以持有和自己场上的怪兽的其中任意种相同种族·属性的自己墓地1只怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- 这个卡名的①②的效果1回合各能使用1次。①：自己怪兽被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。②：这张卡从场上送去墓地的场合，以持有和自己场上的怪兽的其中任意种相同种族·属性的自己墓地1只怪兽为对象才能发动。那只怪兽加入手卡。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetCondition(s.regcon)
		ge1:SetOperation(s.regop)
		-- 注册全局环境效果，用于监听场上怪兽被破坏的事件
		Duel.RegisterEffect(ge1,0)
	end
end
-- 过滤被战斗或效果破坏且原本控制者为指定玩家的怪兽卡
function s.spcfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousControler(tp) and c:IsType(TYPE_MONSTER)
end
-- 检查是否有玩家的怪兽被破坏，并记录被破坏怪兽的控制者（玩家0、玩家1或双方）
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(s.spcfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(s.spcfilter,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
-- 触发自定义事件，向对应玩家发送怪兽被破坏的时点信号
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 触发自定义事件，传递被破坏的卡片组以及受影响的玩家标签
	Duel.RaiseEvent(eg,EVENT_CUSTOM+id,re,r,rp,ep,e:GetLabel())
end
-- 检查触发自定义事件的玩家是否为自己，以此作为特召效果的发动条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ev==tp or ev==PLAYER_ALL
end
-- 特殊召唤效果的发动准备，检查怪兽区域空格及自身是否可特召，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为：将这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的处理，将这张卡从手卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检查这张卡是否是从场上送去墓地，以此作为回收效果的发动条件
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤自己场上表侧表示存在、且与目标卡持有相同种族和属性的怪兽
function s.cfilter(c,race,att)
	return c:IsFaceup() and bit.band(c:GetRace(),race)~=0 and bit.band(c:GetAttribute(),att)~=0
end
-- 过滤自己墓地中，与自己场上某只怪兽持有相同种族和属性的怪兽卡
function s.thfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		-- 检查自己场上是否存在与该墓地怪兽具有相同种族且相同属性的表侧表示怪兽
		and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil,c:GetRace(),c:GetAttribute())
end
-- 回收效果的发动准备，选择墓地中符合条件的怪兽作为对象，并设置加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc,tp) end
	-- 检查自己墓地中是否存在符合回收条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地中1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置当前连锁的操作信息为：将选择的对象怪兽加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回收效果的处理，将作为对象的目标怪兽加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽因效果加入持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

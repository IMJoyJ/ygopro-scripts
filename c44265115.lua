--ブレインコントローラー
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「洗脑」加入手卡。
-- ②：自己把基本分支付的场合，以场上1只表侧表示怪兽为对象，宣言1～8的任意等级才能发动。那只怪兽的等级变成宣言的等级。
-- ③：这张卡作为同调素材送去墓地的场合才能发动。这张卡效果无效在对方场上守备表示特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个触发效果和一个特殊召唤效果
function s.initial_effect(c)
	-- 记录该卡拥有「洗脑」卡名
	aux.AddCodeList(c,87910978)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「洗脑」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己把基本分支付的场合，以场上1只表侧表示怪兽为对象，宣言1～8的任意等级才能发动。那只怪兽的等级变成宣言的等级。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PAY_LPCOST)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.lvcon)
	e3:SetTarget(s.lvtg)
	e3:SetOperation(s.lvop)
	c:RegisterEffect(e3)
	-- ③：这张卡作为同调素材送去墓地的场合才能发动。这张卡效果无效在对方场上守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 检索过滤器，用于筛选卡组中「洗脑」卡
function s.thfilter(c)
	return c:IsCode(87910978) and c:IsAbleToHand()
end
-- 设置检索效果的处理目标，检查卡组中是否存在「洗脑」卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「洗脑」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，提示将要将卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理函数，选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「洗脑」卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 等级变更效果的发动条件，判断是否为玩家支付生命值
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==ep
end
-- 等级变更效果的过滤器，判断目标怪兽是否为表侧表示且等级大于等于1
function s.lvfilter(c,lv)
	return c:IsFaceup() and c:IsLevelAbove(1) and (not lv or not c:IsLevel(lv))
end
-- 设置等级变更效果的目标选择处理，选择目标怪兽并提示宣言等级
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc,e:GetLabel()) end
	-- 检查场上是否存在满足条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local lv=g:GetFirst():GetLevel()
	-- 提示玩家宣言等级
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))  --"请选择要改变的等级"
	-- 获取玩家宣言的等级
	e:SetLabel(Duel.AnnounceLevel(tp,1,8,lv))
end
-- 等级变更效果的处理函数，设置目标怪兽等级
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	local label=e:GetLabel()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and tc:IsLevelAbove(1) and not tc:IsLevel(label) then
		-- 创建等级变更效果，设置目标怪兽等级
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 特殊召唤效果的发动条件，判断是否为同调素材并送去墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 设置特殊召唤效果的目标，检查是否可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以特殊召唤该卡
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp) end
	-- 设置连锁操作信息，提示将要特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数，将该卡特殊召唤并设置效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否在连锁中且未受王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c)
		-- 执行特殊召唤步骤，将该卡特殊召唤到对方场上
		and Duel.SpecialSummonStep(c,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE) then
		-- 创建禁止效果，使该卡无法发动效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 创建无效效果，使该卡效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end

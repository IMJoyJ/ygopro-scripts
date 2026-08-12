--ナイトメア・ペイン
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。自己的手卡·场上（表侧表示）1只暗属性怪兽破坏，除「噩梦之苦痛」外的1只「于贝尔」或者1张有那个卡名记述的卡从卡组加入手卡。
-- ②：只要自己场上有「于贝尔」怪兽存在，可以攻击的对方怪兽必须向「于贝尔」怪兽作出攻击。
-- ③：自己的「于贝尔」怪兽的战斗发生的对自己的战斗伤害由对方代受。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含卡片发动、①效果（破坏并检索）、②效果（强制攻击「于贝尔」怪兽）以及③效果（战斗伤害由对方代受）。
function s.initial_effect(c)
	-- 注册该卡的效果文本中记载了「于贝尔」（卡号78371393）的信息。
	aux.AddCodeList(c,78371393)
	-- 注册该卡的效果文本中记载了「于贝尔」系列怪兽的信息。
	aux.AddSetNameMonsterList(c,0x1a5)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己主要阶段才能发动。自己的手卡·场上（表侧表示）1只暗属性怪兽破坏，除「噩梦之苦痛」外的1只「于贝尔」或者1张有那个卡名记述的卡从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"破坏并检索"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：只要自己场上有「于贝尔」怪兽存在，可以攻击的对方怪兽必须向「于贝尔」怪兽作出攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_MUST_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e4:SetValue(s.atklimit)
	c:RegisterEffect(e4)
	-- ③：自己的「于贝尔」怪兽的战斗发生的对自己的战斗伤害由对方代受。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(s.reftg)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
-- 过滤函数：筛选手卡中或场上表侧表示的暗属性怪兽。
function s.dfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 过滤函数：筛选卡组中除「噩梦之苦痛」以外的「于贝尔」怪兽或记载有「于贝尔」卡名的卡。
function s.thfilter(c,code)
	-- 检查卡片是否为「于贝尔」或记载有「于贝尔」卡名，且可以加入手卡，并且不是同名卡「噩梦之苦痛」。
	return (c:IsCode(78371393) or aux.IsCodeListed(c,78371393)) and c:IsAbleToHand() and not c:IsCode(id)
end
-- ①效果的发动准备与合法性检测函数，检查是否存在可破坏的暗属性怪兽和可检索的卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡或场上是否存在至少1只满足条件的暗属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e,tp)
		-- 并且检查卡组中是否存在至少1张满足检索条件的卡。
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息：预计从自己的手卡或场上破坏1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
	-- 设置连锁处理信息：预计从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的实际处理函数，执行破坏手卡/场上的暗属性怪兽，并将卡组的「于贝尔」相关卡加入手卡的操作。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从手卡或场上选择1只满足条件的暗属性怪兽。
	local g=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 破坏选中的怪兽，若破坏数量小于1（破坏失败）则终止效果处理。
	if Duel.Destroy(g,REASON_EFFECT)<1 then return end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足检索条件的卡。
	local tg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetHandler():GetCode())
	if #g>0 then
		-- 将选中的卡加入手卡。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡。
		Duel.ConfirmCards(1-tp,tg)
	end
end
-- 过滤函数：筛选场上表侧表示的「于贝尔」怪兽。
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a5)
end
-- ②效果的适用条件函数，检查自己场上是否存在表侧表示的「于贝尔」怪兽。
function s.atkcon(e)
	-- 检查自己场上是否存在至少1只表侧表示的「于贝尔」怪兽。
	return Duel.IsExistingMatchingCard(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 限制攻击目标函数：指定攻击目标必须是表侧表示的「于贝尔」怪兽。
function s.atklimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x1a5)
end
-- ③效果的对象筛选函数：指定适用伤害代受效果的对象为自己场上表侧表示的「于贝尔」怪兽。
function s.reftg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x1a5)
end

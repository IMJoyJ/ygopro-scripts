--背信聖徒シルヴィア
-- 效果：
-- 幻想魔族怪兽＋魔法师族·光属性怪兽
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：「背信圣徒 森厄狼母」以外的自己的「蓟花」怪兽给与对方的战斗伤害变成2倍。
-- ②：对方把魔法·陷阱·怪兽的效果发动时，把这张卡解放才能发动。那个效果无效。
-- ③：这张卡被战斗·效果破坏的场合才能发动。从卡组把1张「罪宝」陷阱卡加入手卡。
local s,id,o=GetID()
-- 定义该卡的核心初始化函数：为怪兽赋予融合召唤素材条件与召唤限制，并依次注册①战斗伤害加倍效果、②无效对方效果发动、③被破坏时检索罪宝陷阱的效果
function s.initial_effect(c)
	-- 添加融合召唤手续：融合素材为1只幻想魔族怪兽＋1只满足s.mfilter（光属性·魔法师族）的怪兽，insf=true表示在通常融合基础上追加该素材组合
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_ILLUSION),s.mfilter,true)
	c:EnableReviveLimit()
	-- ①：「背信圣徒 森厄狼母」以外的自己的「蓟花」怪兽给与对方的战斗伤害变成2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.damtg)
	-- 将该效果的数值设为“对方玩家受到己方怪兽战斗伤害变为2倍”，即己方「蓟花」怪兽给对方造成的战斗伤害翻倍
	e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e1)
	-- ②：对方把魔法·陷阱·怪兽的效果发动时，把这张卡解放才能发动。那个效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.discon)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗·效果破坏的场合才能发动。从卡组把1张「罪宝」陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 融合素材判定函数：另一只素材必须为光属性且魔法师族怪兽，与幻想魔族怪兽组合进行融合召唤
function s.mfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_SPELLCASTER)
end
-- 战斗伤害加成的对象判定：仅限自己场上卡名不是「背信圣徒 森厄狼母」的「蓟花」怪兽（其造成的战斗伤害才翻倍）
function s.damtg(e,c)
	return c:IsSetCard(0x1bc) and not c:IsCode(id)
end
-- ②效果的发动条件：当前连锁上的效果由对方玩家发动，且该连锁效果可以被无效化
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 即“效果发动方不是本卡控制者（是对方），并且当前连锁ev的效果能够被无效”
	return ep~=tp and Duel.IsChainDisablable(ev)
end
-- ②效果的代价：检查这张卡能否解放，并在发动时把自身解放作为COST
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 把这张卡以解放为代价送入墓地（REASON_COST表示作为代价，不因“不受效果影响”等而失败）
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- ②效果的发动目标：效果本身不取对象，只要满足条件即可发动；同时设置操作信息，声明要无效的是当前连锁上的效果
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的处理信息为“无效1个效果”，目标为当前连锁的发动源卡eg，数量为1，用于相关效果检测
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ②效果处理：执行将指定连锁的效果无效化的操作
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 将连锁编号ev对应的那个效果无效
	Duel.NegateEffect(ev)
end
-- ③效果的发动条件：本卡被战斗破坏或效果破坏（破坏原因包含REASON_BATTLE或REASON_EFFECT）
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 检索过滤器：卡名属于「罪宝」字段的陷阱卡，并且能够加入手卡
function s.thfilter(c)
	return c:IsSetCard(0x19e) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- ③效果的发动目标：确认卡组存在符合条件的「罪宝」陷阱卡，并设置操作信息为将1张卡加入手卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己的卡组中至少存在1张满足s.thfilter的「罪宝」陷阱卡，否则不能发动
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本效果将把1张卡从卡组加入手卡（目标位置为卡组，目标玩家为效果控制者），用于连锁判定和时点检测
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：提示选择后从卡组选出1张「罪宝」陷阱卡加入手卡，并向对方展示该卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，提示操作者从卡组选择要加入手卡的卡片（HINTMSG_ATOHAND）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让操作者从自己的卡组中挑选1张满足s.thfilter的卡（不取对象，效果处理时选择）
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡（nil表示回到持有者手卡），加入原因视为效果
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示这张被检索加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end

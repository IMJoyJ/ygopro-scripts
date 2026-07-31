--顕現する伝説の都
local s,id,o=GetID()
-- 初始化效果，定义三个主要功能模块：第一个是永续魔陷/场地卡通用的'允许发动'空效果；第二个是一回合一次的起动效果，用于从卡组检索并特殊召唤符合条件的卡到场上；第三个是送入墓地时触发的诱发选发效果，用于将符合条件的水族怪兽回手牌
function s.initial_effect(c)
	-- 记录这张卡片上记载着另外两张卡的代码（38391684 和 22702055），以便后续判断是否满足'同名卡'或特定系列的条件限制。
	aux.AddCodeList(c,38391684,22702055)
	-- 为当前卡片注册一个效果，使其在怪兽区时变更为代码 22702055 对应的卡名（通常用于实现场地卡与魔陷卡的形态切换）。
	aux.EnableChangeCode(c,22702055)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 对应原文：『这张卡的发动成为对方场上的同名卡的效果对象的场合，可以从卡组将1张记载着另一张卡名的卡片特殊召唤到场上。』
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.fttg)
	e1:SetOperation(s.ftop)
	c:RegisterEffect(e1)
	-- 对应原文：『送入墓地的场合，从卡组选择最多1只等级7的海龙族怪兽加入手牌（不取对象）。』
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 定义第一个效果的检索过滤函数，用于检查卡组中的卡是否满足以下条件：代码为 38391684 或 22702055、未被禁用、在场上存在同名卡且类型为场地。
function s.tffilter(c,tp)
	return c:IsCode(38391684,22702055)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
		and c:IsType(TYPE_FIELD)
end
-- 定义第二个效果（起动效果）的目标选择逻辑，判断卡组中是否存在至少一张符合 s.tffilter 过滤条件的卡片。
function s.fttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否至少有1张满足 tffilter 条件（代码匹配、未禁用、场上有同名场地区怪兽）的卡，若存在则允许发动并进入操作阶段。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 定义第二个效果的操作逻辑：提示玩家选择一张符合条件的卡放置到场地正面表示区域；如果选择了卡片，则将其移动到对方或己方场上的场地区。
function s.ftop(e,tp,eg,ep,ev,re,r,rp)
	-- 向当前回合的玩家显示'请选择要放置到场上的卡'的提示信息，准备进行卡片选择流程。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组中选择最多1张符合 s.tffilter 条件的卡片（代码匹配、未禁用、场上有同名场地区怪兽），并获取第一张选中的卡对象 tc。
	local tc=Duel.SelectMatchingCard(tp,s.tffilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 将选中且未被禁用的场地类型卡片移动到当前玩家或对方玩家的场上的场地区，正面表示，并立即适用其效果。
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
-- 定义第三个效果的检索过滤函数，用于检查卡组中是否存在等级7的海龙族怪兽且具备回手牌能力。
function s.thfilter(c)
	return c:IsLevel(7) and c:IsRace(RACE_SEASERPENT) and c:IsAbleToHand()
end
-- 定义第三个效果（墓地触发）的目标选择逻辑：判断卡组中是否至少有1张符合 s.thfilter 条件的卡片；若存在则设置操作信息为'从卡组'类别、数量为1、位置为卡组，并进入操作阶段。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少一张等级7的海龙族怪兽且具备回手牌能力（不取对象），若存在则允许发动效果。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作分类为 CATEGORY_TOHAND（回手牌）、目标卡数量为 1、来源位置为 LOCATION_DECK，用于后续操作信息处理和动画显示。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义第三个效果的操作逻辑：提示玩家选择一张符合条件的卡加入手牌；如果选择了卡片且数量大于0，则将其送入当前玩家的手牌并确认给对方查看。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向当前回合的玩家显示'请选择要加入手牌的卡'的提示信息，准备进行回手牌的选择流程。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择最多1张符合 s.thfilter 条件的卡片（等级7的海龙族怪兽且能回手），用于后续送入玩家手牌的操作。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片组 g 以 REASON_EFFECT 原因送入当前玩家的手牌，并返回实际被操作的卡数量。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认刚刚送入手牌的卡片组 g，以便显示动画和提示效果处理完成。
		Duel.ConfirmCards(1-tp,g)
	end
end

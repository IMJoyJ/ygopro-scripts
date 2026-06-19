--X－セイバー ガトムズ
-- 效果：
-- 调整＋地属性怪兽1只以上
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从卡组把1张「剑士」魔法·陷阱卡或「加特姆士」魔法·陷阱卡加入手卡。
-- ②：这张卡给与对方战斗伤害时才能发动。对方手卡随机1张丢弃。
-- ③：这张卡在墓地存在的状态，自己的「X-剑士」怪兽被选择作为攻击对象时才能发动。这张卡特殊召唤。那之后，攻击对象转移为这张卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含同调召唤手续、同调素材检查以及3个一回合各能使用1次的诱发效果。
function s.initial_effect(c)
	-- 添加同调召唤手续：调整＋地属性怪兽1只以上。
	aux.AddSynchroMixProcedure(c,aux.Tuner(nil),nil,nil,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_EARTH),1,99)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。从卡组把1张「剑士」魔法·陷阱卡或「加特姆士」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡给与对方战斗伤害时才能发动。对方手卡随机1张丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_HANDES_OPPO)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.dhcon)
	e2:SetTarget(s.dhtg)
	e2:SetOperation(s.dhop)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在的状态，自己的「X-剑士」怪兽被选择作为攻击对象时才能发动。这张卡特殊召唤。那之后，攻击对象转移为这张卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- 调整＋地属性怪兽1只以上
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(s.valcheck)
	c:RegisterEffect(e4)
end
-- 检查同调素材中是否包含2只以上的调整怪兽，若是则为自身注册允许将调整作为非调整使用的特殊效果。
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,2,nil,TYPE_TUNER) then
		-- 调整＋地属性怪兽1只以上
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(21142671)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 效果①的发动条件：这张卡同调召唤成功。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤条件：卡组中属于「剑士」或「加特姆士」系列的魔法·陷阱卡，且能加入手牌。
function s.thfilter(c)
	return c:IsSetCard(0xd,0xb0) and c:IsAbleToHand() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果①的发动准备：检查卡组中是否存在符合条件的卡，并设置检索的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张可以加入手牌的「剑士」或「加特姆士」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的运行空间：从卡组选择1张符合条件的卡加入手牌，并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张符合条件的「剑士」或「加特姆士」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡片给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件：给与对方玩家战斗伤害。
function s.dhcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果②的发动准备：检查对方手牌是否可以丢弃，并设置丢弃手牌的操作信息。
function s.dhtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手牌中是否存在至少1张可以因效果丢弃的卡。
	if chk==0 then return Duel.GetMatchingGroupCount(Card.IsDiscardable,tp,0,LOCATION_HAND,nil,REASON_EFFECT)>0 end
	Duel.SetOperationInfo(0,CATEGORY_HANDES_OPPO,nil,0,1-tp,1)
end
-- 效果②的运行空间：随机选择对方1张手牌送去墓地。
function s.dhop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌中所有可以因效果丢弃的卡片组。
	local g=Duel.GetMatchingGroup(Card.IsDiscardable,tp,0,LOCATION_HAND,nil,REASON_EFFECT)
	local sg=g:RandomSelect(1-tp,1)
	-- 将随机选出的对方手牌因效果丢弃送去墓地。
	Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end
-- 效果③的发动条件：自己场上表侧表示的「X-剑士」怪兽被选择作为攻击对象。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击对象（被攻击的怪兽）。
	local d=Duel.GetAttackTarget()
	return d and d:IsControler(tp) and d:IsFaceup() and d:IsSetCard(0x100d)
end
-- 效果③的发动准备：检查自身是否能特殊召唤以及怪兽区域是否有空位，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上的怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息：将这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果③的运行空间：将墓地的这张卡特殊召唤，之后将攻击对象转移为这张卡。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前进行攻击宣言的怪兽。
	local a=Duel.GetAttacker()
	-- 检查这张卡是否仍与连锁相关、是否受王家长眠之谷影响，并尝试将其表侧表示特殊召唤。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		and a:IsAttackable() and a:IsRelateToBattle() and not a:IsImmuneToEffect(e) then
		-- 中断当前效果处理，使后续的攻击对象转移处理不与特殊召唤同时进行（防止错时点）。
		Duel.BreakEffect()
		-- 将对方怪兽的攻击对象转移为这张卡。
		Duel.ChangeAttackTarget(c)
	end
end

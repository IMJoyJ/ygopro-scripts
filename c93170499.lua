--ジュラック・メガロ
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己场上有恐龙族怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己主要阶段才能发动。从手卡选包含「朱罗纪」卡的2张卡丢弃。那之后，自己抽2张。
-- ③：这张卡被战斗·效果破坏的场合才能发动。从卡组·额外卡组把「朱罗纪斑龙」以外的1只「朱罗纪」怪兽送去墓地。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①特召、②丢手牌抽卡、③被破坏送墓三个效果。
function s.initial_effect(c)
	-- 注册该卡在自身效果中记有自身卡名（用于检索或相关效果判定）。
	aux.AddCodeList(c,id)
	-- ①：自己场上有恐龙族怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从手卡选包含「朱罗纪」卡的2张卡丢弃。那之后，自己抽2张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW|CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗·效果破坏的场合才能发动。从卡组·额外卡组把「朱罗纪斑龙」以外的1只「朱罗纪」怪兽送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"送去墓地"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.tgcon)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的恐龙族怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR)
end
-- 效果①的发动条件：自己场上存在表侧表示的恐龙族怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的恐龙族怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动准备与合法性检测（检查怪兽区域空位及自身是否能特殊召唤）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁信息：包含特殊召唤自身的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理：将手牌中的这张卡特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：手牌中可以丢弃的「朱罗纪」卡片。
function s.dhfilter(c)
	return c:IsSetCard(0x22) and c:IsDiscardable()
end
-- 效果②的发动准备与合法性检测（检查是否能抽2张卡以及手牌中是否包含「朱罗纪」卡的2张卡）。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己手牌中的所有卡片。
		local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		-- 检查自己是否能抽2张卡，且手牌中是否存在符合丢弃条件的2张卡（其中至少1张是「朱罗纪」卡）。
		return Duel.IsPlayerCanDraw(tp,2) and g:CheckSubGroup(s.gselect,2,2)
	end
	-- 设置效果处理的对象玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的参数为2（抽2张卡）。
	Duel.SetTargetParam(2)
	-- 设置连锁信息：包含自己抽2张卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 丢弃卡片组合的选择条件：选出的2张卡中必须至少有1张是「朱罗纪」卡，且2张卡都必须能因效果丢弃。
function s.gselect(g)
	return g:IsExists(Card.IsSetCard,1,nil,0x22) and g:FilterCount(Card.IsDiscardable,nil,REASON_EFFECT)==2
end
-- 效果②的处理：丢弃手牌中包含「朱罗纪」卡的2张卡，那之后自己抽2张。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家（自己）和抽卡数量（2张）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 获取目标玩家（自己）的手牌。
	local g=Duel.GetFieldGroup(p,LOCATION_HAND,0)
	if #g>=2 and g:CheckSubGroup(s.gselect,2,2) then
		-- 提示玩家选择要丢弃的手牌。
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		local g1=g:SelectSubGroup(tp,s.gselect,false,2,2)
		-- 如果成功选出2张卡，则将它们作为效果丢弃送去墓地。
		if g1 and g1:GetCount()==2 and Duel.SendtoGrave(g1,REASON_DISCARD+REASON_EFFECT)~=0 then
			-- 中断当前效果处理，使后续的抽卡处理与丢弃手牌不视为同时进行（错时点）。
			Duel.BreakEffect()
			-- 让目标玩家（自己）因效果抽2张卡。
			Duel.Draw(p,d,REASON_EFFECT)
		end
	end
end
-- 效果③的发动条件：这张卡被战斗或者效果破坏。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 过滤条件：卡组·额外卡组中「朱罗纪斑龙」以外的1只「朱罗纪」怪兽。
function s.tgfilter(c)
	return not c:IsCode(id) and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x22) and c:IsAbleToGrave()
end
-- 效果③的发动准备与合法性检测（检查卡组或额外卡组是否存在可送去墓地的符合条件的怪兽）。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组或额外卡组中是否存在「朱罗纪斑龙」以外的「朱罗纪」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁信息：包含从卡组或额外卡组将1张卡送去墓地的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果③的处理：从卡组·额外卡组把「朱罗纪斑龙」以外的1只「朱罗纪」怪兽送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己的卡组或额外卡组中选择1只「朱罗纪斑龙」以外的「朱罗纪」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽因效果送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

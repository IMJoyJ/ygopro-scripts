--DDカウント・サーベイヤー
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，自己把「DDD」怪兽灵摆召唤的场合，以对方场上3只种族相同的怪兽或3只属性相同的怪兽为对象才能发动。那3只表侧表示怪兽之内的2只解放。剩下的1只的攻击力·守备力上升解放的怪兽的各自数值的合计。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：从手卡丢弃1只其他的「DD」怪兽才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。把1只攻击力或守备力是0的「DD」怪兽从卡组加入手卡。
local s,id,o=GetID()
-- 注册灵摆怪兽属性；创建灵摆区『解放怪兽』诱发效果（对应灵摆①）、手牌『特殊召唤』起动效果（对应怪兽①）和召唤成功时『检索』诱发效果（对应怪兽②），并克隆检索效果以处理特殊召唤成功时的情况。
function s.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以作为灵摆卡发动并支持灵摆召唤。
	aux.EnablePendulumAttribute(c)
	-- 「①：1回合1次，自己把「DDD」怪兽灵摆召唤的场合，以对方场上3只种族相同的怪兽或3只属性相同的怪兽为对象才能发动。那3只表侧表示怪兽之内的2只解放。剩下的1只的攻击力·守备力上升解放的怪兽的各自数值的合计。」
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"解放怪兽"
	e1:SetCategory(CATEGORY_RELEASE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1)
	e1:SetCondition(s.rlcon)
	e1:SetTarget(s.rltg)
	e1:SetOperation(s.rlop)
	c:RegisterEffect(e1)
	-- 「①：从手卡丢弃1只其他的「DD」怪兽才能发动。这张卡从手卡特殊召唤。」
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 「②：这张卡召唤·特殊召唤的场合才能发动。把1只攻击力或守备力是0的「DD」怪兽从卡组加入手卡。」（此处为召唤成功时的注册部分，特殊召唤部分由后续克隆效果实现）
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"检索效果"
	e3:SetCategory(CATEGORY_SEARCH|CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,id+o)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 过滤条件：判定怪兽是否表侧表示、属于「DDD」系列（0x10af）、由tp玩家灵摆召唤。
function s.rlcfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x10af) and c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 触发条件：本次特殊召唤成功的事件怪兽中存在至少1只由tp玩家灵摆召唤的表侧表示「DDD」怪兽。
function s.rlcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.rlcfilter,1,nil,tp)
end
-- 候选对象过滤器：怪兽需表侧表示且能成为效果对象（即可被取对象）。
function s.rlfilter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
-- 检查组条件：所有怪兽拥有相同种族或相同属性，且其中存在1只作为留在场上的话，其余2只均可被效果解放。
function s.gcheck(g)
	-- 通过位掩码检查所有候选怪兽的种族是否全部相同，或属性是否全部相同。
	return (Auxiliary.SameValueCheck(g,Card.GetRace) or Auxiliary.SameValueCheck(g,Card.GetAttribute))
		and g:IsExists(s.atkfilter,1,nil,g)
end
-- 发动时选择对象：从对方场上挑选3只满足条件的表侧怪兽；若存在可选组合，提示玩家选择并设为效果对象，同时设置将解放其中2只的操作信息。
function s.rltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取对方怪兽区所有表侧表示且能成为效果对象的怪兽，作为候选组g。
	local g=Duel.GetMatchingGroup(s.rlfilter,tp,0,LOCATION_MZONE,nil,e)
	if chkc then return false end
	if chk==0 then return g:CheckSubGroup(s.gcheck,3,3) end
	-- 显示选择对象的提示信息，要求玩家选择效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,3,3)
	-- 将选中的3只怪兽设置为当前连锁的效果对象。
	Duel.SetTargetCard(sg)
	-- 将本次效果将解放2只对象怪兽的信息写入连锁操作信息。
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,sg,2,0,0)
end
-- 判断c作为留在场上的怪兽时，其余2只怪兽是否都能被效果解放；用于选择保留哪1只。
function s.atkfilter(c,g)
	local sg=g:Clone()
	sg:Sub(Group.FromCards(c))
	return sg:FilterCount(Card.IsReleasableByEffect,nil)==2
end
-- 效果处理时筛选对象：仍是本效果对象且表侧表示的怪兽。
function s.crlfilteer(c,e)
	return c:IsRelateToEffect(e) and c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- 效果处理：从对象中选1只留在场上，解放其余2只；若解放成功，将解放怪兽离场前的攻击力与守备力合计分别加到留下怪兽的攻击力和守备力上。
function s.rlop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出当前连锁记录的对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(s.crlfilteer,nil,e)
	if tg:GetCount()~=3 then return end
	-- 提示玩家选择留在场上的1只怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))  --"请选择留在场上的怪兽"
	local sg=tg:FilterSelect(tp,s.atkfilter,1,1,nil,g)
	if sg:GetCount()>0 then
		tg:Sub(sg)
		-- 为将被解放的2只怪兽显示被选中的动画效果，并记录它们成为广义对象。
		Duel.HintSelection(tg)
		-- 以效果解放选中的2只怪兽，返回实际解放数量。
		local rc=Duel.Release(tg,REASON_EFFECT)
		if rc>0 then
			-- 获取上一次实际被解放的怪兽组，用于计算攻击力·守备力上升值。
			local rg=Duel.GetOperatedGroup()
			local atk=rg:GetSum(Card.GetPreviousAttackOnField)
			local def=rg:GetSum(Card.GetPreviousDefenseOnField)
			local tc=sg:GetFirst()
			-- 「剩下的1只的攻击力上升解放的怪兽的各自数值的合计。」（对应原文攻击力部分）
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 「剩下的1只的守备力上升解放的怪兽的各自数值的合计。」（对应原文守备力部分）
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			e2:SetValue(def)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
end
-- 丢弃cost的筛选条件：怪兽、「DD」系列（0xaf）、可以从手牌丢弃。
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xaf) and c:IsDiscardable()
end
-- cost检查与执行：确认手牌存在满足条件的「DD」怪兽后，丢弃1张作为发动费用。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 费用检测阶段：检查手牌是否有1张「DD」怪兽可以丢弃。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际执行cost：从手牌选择并丢弃1张「DD」怪兽（作为cost）。
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 特殊召唤的发动条件：自己怪兽区有空位，且这张卡本身可以特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上怪兽区是否有空余位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次连锁将特殊召唤这张卡的操作信息写入。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与本连锁相关，则将其表侧表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到持有者场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 检索筛选条件：「DD」怪兽，攻击力或守备力为0，且可以加入手牌。
function s.thfilter(c)
	return c:IsSetCard(0xaf) and c:IsType(TYPE_MONSTER)
		and (c:IsAttack(0) or c:IsDefense(0)) and c:IsAbleToHand()
end
-- 检索效果的发动条件与操作信息：卡组存在符合条件的「DD」怪兽时，设置从卡组将1张加入手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在1张符合检索条件的「DD」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 将本次连锁从卡组将1张卡加入手牌的操作信息写入。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果处理：从卡组选择1只符合条件的「DD」怪兽加入手牌，并向对方展示确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择要加入手牌的卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足检索条件的「DD」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡加入持有者手牌（此处发送给其持有者）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手牌的那张卡展示给对手确认。
		Duel.ConfirmCards(1-tp,g)
	end
end

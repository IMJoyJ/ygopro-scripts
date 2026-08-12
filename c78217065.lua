--エヴォリューション・レザルト・バースト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1张「超载融合」加入手卡。这个回合中，「超载融合」的效果用6只以上的怪兽为素材作融合召唤的场合，那只怪兽在这个回合在同1次的战斗阶段中可以作出最多有那些作为融合素材的怪兽数量的攻击。这张卡的发动后，直到回合结束时自己不用魔法卡的效果不能把怪兽特殊召唤。
function c78217065.initial_effect(c)
	-- ①：从卡组把1张「超载融合」加入手卡。这个回合中，「超载融合」的效果用6只以上的怪兽为素材作融合召唤的场合，那只怪兽在这个回合在同1次的战斗阶段中可以作出最多有那些作为融合素材的怪兽数量的攻击。这张卡的发动后，直到回合结束时自己不用魔法卡的效果不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,78217065+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c78217065.target)
	e1:SetOperation(c78217065.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中卡名为「超载融合」且可以加入手牌的卡片
function c78217065.thfilter(c)
	return c:IsCode(3659803) and c:IsAbleToHand()
end
-- 效果发动的准备阶段，检查卡组中是否存在「超载融合」并设置检索的操作信息
function c78217065.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1张可以加入手牌的「超载融合」
	if chk==0 then return Duel.IsExistingMatchingCard(c78217065.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息，表示该效果会将卡组的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的核心逻辑，执行检索「超载融合」并注册后续的融合召唤强化效果和特殊召唤限制
function c78217065.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张「超载融合」
	local g=Duel.SelectMatchingCard(tp,c78217065.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个回合中，「超载融合」的效果用6只以上的怪兽为素材作融合召唤的场合，那只怪兽在这个回合在同1次的战斗阶段中可以作出最多有那些作为融合素材的怪兽数量的攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c78217065.excon)
	e1:SetOperation(c78217065.exop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境中注册该回合内检测「超载融合」融合召唤的事件监听效果
	Duel.RegisterEffect(e1,tp)
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时自己不用魔法卡的效果不能把怪兽特殊召唤。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c78217065.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境中注册该回合内自己不能用魔法卡以外的效果特殊召唤怪兽的限制
	Duel.RegisterEffect(e2,tp)
end
-- 过滤出通过融合召唤登场且融合素材数量在6只以上的融合怪兽
function c78217065.cfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsSummonType(SUMMON_TYPE_FUSION) and c:GetMaterialCount()>=6
end
-- 检查触发特殊召唤的效果是否为「超载融合」，且召唤出的怪兽中是否存在满足6只以上素材条件的融合怪兽
function c78217065.excon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsCode(3659803) and eg:IsExists(c78217065.cfilter,1,nil)
end
-- 为满足条件的融合怪兽注册追加攻击次数的效果
function c78217065.exop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:Filter(c78217065.cfilter,nil):GetFirst()
	-- 那只怪兽在这个回合在同1次的战斗阶段中可以作出最多有那些作为融合素材的怪兽数量的攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(tc:GetMaterialCount()-1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
end
-- 限制特殊召唤的来源，若不是由魔法卡的效果引起的特殊召唤则无法进行
function c78217065.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not se:GetHandler():IsType(TYPE_SPELL)
end

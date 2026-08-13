--ペンデュラム・エリア
-- 效果：
-- ①：自己场上的怪兽只有灵摆怪兽的场合，以自己的灵摆区域2张卡为对象才能发动。那2张卡破坏，这个回合双方不能作灵摆召唤以外的特殊召唤。
function c2359348.initial_effect(c)
	-- ①：自己场上的怪兽只有灵摆怪兽的场合，以自己的灵摆区域2张卡为对象才能发动。那2张卡破坏，这个回合双方不能作灵摆召唤以外的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c2359348.condition)
	e1:SetTarget(c2359348.target)
	e1:SetOperation(c2359348.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选函数：卡片必须是表侧表示且为灵摆怪兽，用于判定己方场上怪兽是否全是灵摆怪兽。
function c2359348.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- 发动条件判定：获取己方场上怪兽组，若存在怪兽且所有怪兽都通过上述筛选，即己方场上怪兽只有灵摆怪兽，则满足发动条件。
function c2359348.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 取得己方场上的全部怪兽（主要怪兽区和额外怪兽区）。
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return g:GetCount()>0 and g:FilterCount(c2359348.cfilter,nil)==g:GetCount()
end
-- 发动时的目标选择与操作信息设定：若自己灵摆区存在至少2张可对象卡，则将己方灵摆区的所有卡设为对象，并设定将破坏2张卡的操作信息。
function c2359348.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动时的合法性检查：确认自己灵摆区存在至少2张卡可作为效果对象（不取对象限制，任意卡均可）。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_PZONE,0,2,nil) end
	-- 取得己方灵摆区的全部卡（通常为2张）。
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	-- 将选定的灵摆区卡登记为当前连锁的对象，使这些卡与效果建立联系。
	Duel.SetTargetCard(g)
	-- 设置操作信息：声明该效果为破坏效果，预定破坏对象为g，数量为2，供其他卡连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 效果处理：获取连锁对象中仍与效果相关的卡，若仍有2张且都被效果破坏，则给双方附加本回合不能作灵摆召唤以外特殊召唤的限制效果。
function c2359348.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理中登记的对象卡组，即发动时选择的己方灵摆区2张卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 判定对象卡仍然存在且均成功被效果破坏；满足该条件才继续附加特殊召唤限制。
	if sg:GetCount()==2 and Duel.Destroy(sg,REASON_EFFECT)==2 then
		-- 这个回合双方不能作灵摆召唤以外的特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(1,1)
		e1:SetTarget(c2359348.splimit)
		-- 将特殊召唤限制效果注册到发动玩家tp，使其作为一个影响双方玩家的场地效果开始生效。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制效果的判定函数：检查特殊召唤的召唤类型，若不是灵摆召唤（SUMMON_TYPE_PENDULUM）则禁止该特殊召唤。
function c2359348.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)~=SUMMON_TYPE_PENDULUM
end

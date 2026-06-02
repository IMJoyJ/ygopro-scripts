--ガトリング・オーガ
-- 效果：
-- 这个卡名的①的效果1回合可以使用最多3次。
-- ①：把自己的魔法与陷阱区域的里侧表示卡任意数量送去墓地才能发动。给与对方送去墓地的数量×800伤害。这个效果的发动后，直到回合结束时恶魔族以外的怪兽的效果让对方受到的全部效果伤害变成0。
-- ②：1回合1次，这张卡被选择作为攻击对象时才能发动。给与对方为对方场上的攻击表示怪兽数量×500伤害。那之后，战斗阶段结束。
local s,id,o=GetID()
-- 注册卡片效果：包含①把魔陷区任意数量里侧魔陷送墓，给与对方送墓数×800伤害，且发动后直到回合结束恶魔族以外怪兽导致的效果伤害归零的起动效果；以及②一回合一次，被选为攻击对象时，给与对方其攻击表示怪兽数×500伤害并结束战斗阶段的诱发效果。
function s.initial_effect(c)
	-- ①：把自己的魔法与陷阱区域的里侧表示卡任意数量送去墓地才能发动。给与对方送去墓地的数量×800伤害。这个效果的发动后，直到回合结束时恶魔族以外的怪兽的效果让对方受到的全部效果伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"给与伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(3,id)
	e1:SetCost(s.damcost)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，这张卡被选择作为攻击对象时才能发动。给与对方为对方场上的攻击表示怪兽数量×500伤害。那之后，战斗阶段结束。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"给与伤害并结束战斗阶段"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(s.damtg2)
	e2:SetOperation(s.damop2)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己魔陷区中可以作为代价送去墓地的里侧表示卡。
function s.costfilter(c)
	return c:IsFacedown() and c:IsAbleToGraveAsCost() and c:GetSequence()<5
end
-- 效果①发动的代价：将自己魔陷区里侧表示的卡任意数量送去墓地，并记录送去墓地的卡片数量。
function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果①发动前，检查自己魔陷区是否存在至少1张里侧表示的卡可以送去墓地。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的里侧表示卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己魔陷区选择1至5张里侧表示卡片（不含此卡）。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_SZONE,0,1,5,e:GetHandler())
	-- 将选择的卡送去墓地，作为效果发动的代价。
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetCount())
end
-- 效果①的发动检测：确认伤害玩家为对方，并根据代价值注册给与对方伤害的连锁信息。
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	local ct=e:GetLabel()
	-- 设定受到效果伤害的玩家为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 设定伤害的参数值为送去墓地的卡片数量乘以800。
	Duel.SetTargetParam(ct*800)
	-- 设置连锁信息：包含对对方玩家造成指定数值效果伤害的效果分类。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*800)
end
-- 效果①的效果处理：给与对方计算后的效果伤害，并注册直到回合结束恶魔族以外怪兽导致的效果伤害变成0的全局变更效果。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中获取被设定为伤害目标的玩家以及伤害数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 通过效果对目标玩家造成指定数值的效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
	-- 这个效果的发动后，直到回合结束时恶魔族以外的怪兽的效果让对方受到的全部效果伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.damcon)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境中注册该限制在回合结束前生效的伤害变更效果。
	Duel.RegisterEffect(e1,tp)
end
-- 判断效果伤害的来源：若是非恶魔族怪兽的效果造成的伤害，则该伤害值变更为0。
function s.damcon(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 and re and re:IsActiveType(TYPE_MONSTER) then
		if re:GetHandler():IsRace(RACE_FIEND) then return val else return 0 end
	else
		return val
	end
end
-- 过滤条件：对方场上处于攻击表示的怪兽。
function s.filter(c)
	return c:IsPosition(POS_ATTACK)
end
-- 效果②的发动检测：检查对方场上是否存在攻击表示怪兽，设定伤害玩家为对方，并设定对方场上攻击表示怪兽数×500的伤害数值。
function s.damtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果②发动前，检查对方场上是否存在至少1只表侧攻击表示的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有处于攻击表示的怪兽的总数量。
	local ct=Duel.GetMatchingGroupCount(s.filter,tp,0,LOCATION_MZONE,nil)
	-- 设定受到效果伤害的玩家为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 设定伤害的参数值为对方攻击表示怪兽的数量乘以500。
	Duel.SetTargetParam(ct*500)
	-- 设置连锁信息：包含对对方造成指定数值效果伤害的效果分类。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*500)
end
-- 效果②的效果处理：给与对方原本攻击表示怪兽数×500点伤害，那之后强制结束战斗阶段。
function s.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上处于攻击表示的怪兽的总数量。
	local ct=Duel.GetMatchingGroupCount(s.filter,tp,0,LOCATION_MZONE,nil)
	-- 从当前连锁中获取被设定为伤害目标的玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 若成功给与了对方玩家对应数值的效果伤害。
	if Duel.Damage(p,ct*500,REASON_EFFECT)~=0 then
		-- 中断当前效果，使得强制结束战斗阶段的处理与伤害的结算不同时发生。
		Duel.BreakEffect()
		-- 跳过战斗阶段的其他步骤，直接进入战斗阶段结束步骤，从而强制结束战斗阶段。
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end

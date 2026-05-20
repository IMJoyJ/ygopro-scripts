--機皇神マシニクル∞
-- 效果：
-- 这张卡不能通常召唤。从手卡把3只「机皇」怪兽送去墓地的场合才能特殊召唤。
-- ①：1回合1次，以对方场上1只同调怪兽为对象才能发动。那只对方同调怪兽给这张卡装备。
-- ②：这个攻击力上升自身的效果装备的怪兽的攻击力数值。
-- ③：自己准备阶段，把自身的效果装备的1只自己怪兽送去墓地才能发动。给与对方那只怪兽的攻击力数值的伤害。这个效果发动的回合，自己不能进行战斗阶段。
function c63468625.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(0)
	c:RegisterEffect(e1)
	-- 从手卡把3只「机皇」怪兽送去墓地的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c63468625.spcon)
	e2:SetTarget(c63468625.sptg)
	e2:SetOperation(c63468625.spop)
	c:RegisterEffect(e2)
	-- ①：1回合1次，以对方场上1只同调怪兽为对象才能发动。那只对方同调怪兽给这张卡装备。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(63468625,0))  --"装备"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c63468625.eqtg)
	e3:SetOperation(c63468625.eqop)
	c:RegisterEffect(e3)
	-- ③：自己准备阶段，把自身的效果装备的1只自己怪兽送去墓地才能发动。给与对方那只怪兽的攻击力数值的伤害。这个效果发动的回合，自己不能进行战斗阶段。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(63468625,1))  --"伤害"
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c63468625.damcon)
	e4:SetCost(c63468625.damcost)
	e4:SetTarget(c63468625.damtg)
	e4:SetOperation(c63468625.damop)
	c:RegisterEffect(e4)
end
-- 过滤手卡中可作为特殊召唤Cost送去墓地的「机皇」怪兽
function c63468625.spfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x13) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤规则的条件判定：检查怪兽区域空位以及手卡中是否存在3只满足条件的「机皇」怪兽
function c63468625.spcon(e,c)
	if c==nil then return true end
	-- 判定自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判定手卡中是否存在至少3只除自身以外满足过滤条件的「机皇」怪兽
		and Duel.IsExistingMatchingCard(c63468625.spfilter,c:GetControler(),LOCATION_HAND,0,3,c)
end
-- 特殊召唤规则的卡片选择：从手卡选择3只满足条件的「机皇」怪兽并保存
function c63468625.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手卡中除自身以外所有满足过滤条件的「机皇」怪兽组
	local g=Duel.GetMatchingGroup(c63468625.spfilter,tp,LOCATION_HAND,0,c)
	-- 向玩家发送选择送去墓地的卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:CancelableSelect(tp,3,3,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行：将选定的3只「机皇」怪兽送去墓地以完成特殊召唤
function c63468625.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的卡片作为特殊召唤的Cost送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
end
-- 过滤对方场上表侧表示、可改变控制权的同调怪兽
function c63468625.eqfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAbleToChangeControler()
end
-- 装备效果的发动准备：检查魔法与陷阱区域空位并选择对方场上1只同调怪兽作为效果对象
function c63468625.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c63468625.eqfilter(chkc) end
	-- 在发动效果的步骤0，检查自己场上是否有可用的魔法与陷阱区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查对方场上是否存在至少1只满足过滤条件的同调怪兽
		and Duel.IsExistingTarget(c63468625.eqfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择装备卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择对方场上1只满足过滤条件的同调怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c63468625.eqfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 装备限制条件：装备卡仅在装备怪兽未被无效且装备卡持有者为本卡时有效
function c63468625.eqlimit(e,c)
	return e:GetOwner()==c and not c:IsDisabled()
end
-- 装备效果的执行：将对象怪兽作为装备卡装备给自身，并使其攻击力上升该怪兽的攻击力数值
function c63468625.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为对象的第一张卡（即要装备的同调怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		local atk=tc:GetTextAttack()
		if atk<0 then atk=0 end
		-- 尝试将目标怪兽作为装备卡装备给自身，若装备失败则终止效果处理
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 那只对方同调怪兽给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c63468625.eqlimit)
		tc:RegisterEffect(e1)
		-- ②：这个攻击力上升自身的效果装备的怪兽的攻击力数值。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
		tc:RegisterFlagEffect(63468625,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
-- 伤害效果的发动条件判定：必须在自己的回合
function c63468625.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 过滤自身效果装备的、且可以作为Cost送去墓地的怪兽卡
function c63468625.dcfilter(c)
	return c:GetFlagEffect(63468625)~=0 and c:IsAbleToGraveAsCost()
end
-- 伤害效果的Cost处理：检查并选择自身效果装备的1只怪兽送去墓地，并注册本回合不能进行战斗阶段的限制
function c63468625.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEquipGroup():IsExists(c63468625.dcfilter,1,nil) end
	-- 向玩家发送选择送去墓地的卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local g=e:GetHandler():GetEquipGroup():FilterSelect(tp,c63468625.dcfilter,1,1,nil)
	-- 将选定的装备怪兽作为Cost送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	-- ③：自己准备阶段，把自身的效果装备的1只自己怪兽送去墓地才能发动。给与对方那只怪兽的攻击力数值的伤害。这个效果发动的回合，自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册本回合不能进行战斗阶段的限制效果
	Duel.RegisterEffect(e1,tp)
	local atk=g:GetFirst():GetTextAttack()
	if atk<0 then atk=0 end
	e:SetLabel(atk)
end
-- 伤害效果的目标设定：设定对方玩家为伤害对象，并记录伤害数值
function c63468625.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设定为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设定为之前保存的送去墓地怪兽的攻击力数值
	Duel.SetTargetParam(e:GetLabel())
	-- 设置当前连锁的操作信息为：给与对方玩家对应数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
end
-- 伤害效果的执行：获取目标玩家和伤害数值，并给与对方玩家效果伤害
function c63468625.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end

--機皇神龍アステリスク
-- 效果：
-- 这张卡不能通常召唤。自己场上的「机皇」怪兽是3只以上的场合可以特殊召唤。
-- ①：这张卡特殊召唤成功时，以这张卡以外的自己场上的「机皇」怪兽任意数量为对象才能发动。那些自己的「机皇」怪兽送去墓地。这张卡的攻击力变成这个效果送去墓地的怪兽的原本攻击力合计数值。
-- ②：每次同调怪兽特殊召唤发动。给与把那些怪兽特殊召唤的玩家1000伤害。
function c38522377.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。自己场上的「机皇」怪兽是3只以上的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c38522377.spcon)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤成功时，以这张卡以外的自己场上的「机皇」怪兽任意数量为对象才能发动。那些自己的「机皇」怪兽送去墓地。这张卡的攻击力变成这个效果送去墓地的怪兽的原本攻击力合计数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38522377,0))  --"攻击变化"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOGRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c38522377.atktg)
	e2:SetOperation(c38522377.atkop)
	c:RegisterEffect(e2)
	-- ②：每次同调怪兽特殊召唤发动。给与把那些怪兽特殊召唤的玩家1000伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(38522377,1))  --"LP伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c38522377.damcon)
	e3:SetTarget(c38522377.damtg)
	e3:SetOperation(c38522377.damop)
	c:RegisterEffect(e3)
end
-- 判断怪兽是否为表侧表示的「机皇」怪兽，用于特殊召唤条件和①效果的对象筛选。
function c38522377.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x13)
end
-- 特殊召唤规则的发动条件：c为空时视为规则询问返回true；否则要求自己场上有空余怪兽区域，且自己场上有3只以上的表侧「机皇」怪兽。
function c38522377.spcon(e,c)
	if c==nil then return true end
	-- 检查该特殊召唤的玩家是否有可用的怪兽区域。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查该玩家场上是否有至少3只表侧表示的「机皇」怪兽（从自己怪兽区域检索，无排除卡）。
		and Duel.IsExistingMatchingCard(c38522377.spfilter,c:GetControler(),LOCATION_MZONE,0,3,nil)
end
-- ①效果的取对象流程：特殊召唤成功时，从自己场上选择这张卡以外的任意数量表侧「机皇」怪兽作为对象（1～7张），并登记“送去墓地”的操作信息。
function c38522377.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 发动时合法检查：确认至少存在1张能作为对象的表侧「机皇」怪兽（且不是这张卡本身）。
	if chk==0 then return Duel.IsExistingTarget(c38522377.spfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要送去墓地的卡（HINTMSG_TOGRAVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从自己场上选择1～7张除自身以外的表侧「机皇」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c38522377.spfilter,tp,LOCATION_MZONE,0,1,7,e:GetHandler())
	-- 设置操作信息：将选中的对象卡组作为本次效果确定送去墓地的卡，数量为g:GetCount()。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 过滤对象卡：处理时仍与效果相关且表侧表示的卡才保留（防止对象已经离场或变成里侧）。
function c38522377.atkfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsFaceup()
end
-- ①效果处理：将保留下来的对象卡送去墓地；若这张卡仍在场上且表侧，则根据这次送入墓地的卡的原攻击力合计，以最终攻击力设定形式改变这张卡的攻击力，并设置重置条件。
function c38522377.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取回发动时选择的对象，并排除已与效果失去联系或不是表侧表示的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c38522377.atkfilter,nil,e)
	-- 将选择的对象卡从场上送去墓地（原因：效果）。
	Duel.SendtoGrave(g,REASON_EFFECT)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取本次效果实际送入墓地的卡组，并筛选出位于墓地的卡，用于计算原攻击力合计。
	local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	local atk=og:GetSum(Card.GetBaseAttack)
	-- 这张卡的攻击力变成这个效果送去墓地的怪兽的原本攻击力合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- ②效果的发动条件：当前特殊召唤成功的怪兽组中存在至少1只同调怪兽。
function c38522377.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,nil,TYPE_SYNCHRO)
end
-- ②效果的target流程：无对象，但需要判断同调怪兽的召唤玩家，以便决定伤害对象；若效果发动玩家tp召唤的同调怪兽存在则对tp造成伤害，若是对方则对1-tp造成伤害，若双方都存在则对双方造成伤害，并登记对应的伤害操作信息。
function c38522377.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local t1=false
	local t2=false
	local tc=eg:GetFirst()
	while tc do
		if tc:IsType(TYPE_SYNCHRO) then
			if tc:IsSummonPlayer(tp) then t1=true else t2=true end
		end
		tc=eg:GetNext()
	end
	-- 只有tp玩家召唤了同调怪兽时，设置对tp玩家造成1000伤害的操作信息。
	if t1 and not t2 then Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,1000)
	-- 只有对方（1-tp）召唤了同调怪兽时，设置对对方造成1000伤害的操作信息。
	elseif not t1 and t2 then Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
	-- 双方都有召唤同调怪兽时，设置对双方各造成1000伤害的操作信息。
	else Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,1000) end
end
-- ②效果处理：根据登记的操作信息对对应玩家造成1000点效果伤害；若需要对双方造成伤害，则使用分解步骤方式分别伤害并调用Duel.RDComplete()完成时点处理。
function c38522377.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从操作信息中取出伤害对象玩家dp以及伤害值dv等参数。
	local ex,g,gc,dp,dv=Duel.GetOperationInfo(0,CATEGORY_DAMAGE)
	-- 如果伤害对象不是双方，则对指定玩家dp造成1000点效果伤害。
	if dp~=PLAYER_ALL then Duel.Damage(dp,1000,REASON_EFFECT)
	else
		-- 以分解步骤方式对tp玩家造成1000点效果伤害。
		Duel.Damage(tp,1000,REASON_EFFECT,true)
		-- 以分解步骤方式对对方玩家造成1000点效果伤害。
		Duel.Damage(1-tp,1000,REASON_EFFECT,true)
		-- 完成分解步骤的伤害处理，触发伤害相关时点（如受伤时点、LP变动时点）。
		Duel.RDComplete()
	end
end

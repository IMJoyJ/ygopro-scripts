--No.58 炎圧鬼バーナー・バイサー
-- 效果：
-- 4星怪兽×2
-- ①：1回合1次，可以从以下效果选择1个发动。
-- ●以自己场上1只超量怪兽为对象，把这张卡当作装备卡使用给那只怪兽装备。
-- ●装备的这张卡攻击表示特殊召唤。
-- ②：装备怪兽可以向对方直接攻击。
-- ③：装备怪兽给与对方战斗伤害时，丢弃1张手卡才能发动。给与对方500伤害。
function c93108839.initial_effect(c)
	-- 为卡片添加XYZ召唤手续：4星怪兽×2
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ●以自己场上1只超量怪兽为对象，把这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93108839,0))  --"装备"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c93108839.eqtg)
	e1:SetOperation(c93108839.eqop)
	c:RegisterEffect(e1)
	-- ●装备的这张卡攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93108839,1))  --"LP伤害"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(c93108839.sptg)
	e2:SetOperation(c93108839.spop)
	c:RegisterEffect(e2)
	-- ②：装备怪兽可以向对方直接攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e3)
	-- ③：装备怪兽给与对方战斗伤害时，丢弃1张手卡才能发动。给与对方500伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(93108839,2))
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c93108839.damcon)
	e4:SetCost(c93108839.damcost)
	e4:SetTarget(c93108839.damtg)
	e4:SetOperation(c93108839.damop)
	c:RegisterEffect(e4)
end
-- 设置该卡片的「No.」编号为58
aux.xyz_number[93108839]=58
-- 过滤条件：场上表侧表示的超量怪兽
function c93108839.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 装备效果的发动准备与对象选择函数
function c93108839.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c93108839.filter(chkc) and chkc~=e:GetHandler() end
	-- 检查本回合是否尚未发动过该效果，且己方魔陷区有空位
	if chk==0 then return e:GetHandler():GetFlagEffect(93108839)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查己方场上是否存在除自身以外的、可作为装备对象的超量怪兽
		and Duel.IsExistingTarget(c93108839.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 设置选择装备卡时的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择己方场上1只超量怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c93108839.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置效果分类为装备，并指定对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(93108839,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 装备效果的执行函数
function c93108839.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的第一个对象
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() or tc:IsControler(1-tp) then
		-- 若装备对象不合法，则将自身送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将自身作为装备卡装备给目标怪兽，若失败则返回
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 把这张卡当作装备卡使用给那只怪兽装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c93108839.eqlimit)
	e4:SetReset(RESET_EVENT+RESETS_STANDARD)
	e4:SetLabelObject(tc)
	c:RegisterEffect(e4)
end
-- 装备限制函数，规定该卡只能装备给作为对象的那只怪兽
function c93108839.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 特殊召唤效果的发动准备与条件判定函数
function c93108839.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查本回合是否尚未发动过该效果，且己方怪兽区有空位
	if chk==0 then return c:GetFlagEffect(93108839)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:GetEquipTarget() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 设置效果分类为特殊召唤，并指定自身为特殊召唤对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	c:RegisterFlagEffect(93108839,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 特殊召唤效果的执行函数
function c93108839.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧攻击表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_ATTACK)
end
-- 伤害效果的发动条件判定：装备怪兽给与对方战斗伤害时
function c93108839.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and eg:GetFirst()==e:GetHandler():GetEquipTarget()
end
-- 伤害效果的Cost判定与执行函数
function c93108839.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方手卡中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃1张手卡作为发动的代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 伤害效果的发动准备与参数设定函数
function c93108839.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的对象参数为500
	Duel.SetTargetParam(500)
	-- 设置效果分类为伤害，并指定伤害数值与对象玩家
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 伤害效果的执行函数
function c93108839.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家对应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end

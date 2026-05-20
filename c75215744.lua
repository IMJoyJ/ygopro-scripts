--弩級軍貫－いくら型一番艦
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡超量召唤成功的场合才能发动。那些作为超量召唤的素材的怪兽的以下效果适用。
-- ●「舍利军贯」：自己从卡组抽1张。
-- ●「鲑鱼子军贯」：这张卡在同1次的战斗阶段中可以作2次攻击。
-- ②：1回合1次，从额外卡组特殊召唤的自己的「军贯」怪兽给与对方战斗伤害时，以对方场上1张卡为对象才能发动。那张卡破坏。
function c75215744.initial_effect(c)
	-- 注册卡片脚本中关联的卡片密码（「舍利军贯」与「鲑鱼子军贯」）
	aux.AddCodeList(c,24639891,61027400)
	-- 添加超量召唤手续：4星怪兽×2
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 那些作为超量召唤的素材的怪兽的以下效果适用。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(c75215744.valcheck)
	c:RegisterEffect(e0)
	-- ①：这张卡超量召唤成功的场合才能发动。那些作为超量召唤的素材的怪兽的以下效果适用。●「舍利军贯」：自己从卡组抽1张。●「鲑鱼子军贯」：这张卡在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75215744,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,75215744)
	e1:SetCondition(c75215744.effcon)
	e1:SetTarget(c75215744.efftg)
	e1:SetOperation(c75215744.effop)
	c:RegisterEffect(e1)
	e0:SetLabelObject(e1)
	-- ②：1回合1次，从额外卡组特殊召唤的自己的「军贯」怪兽给与对方战斗伤害时，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75215744,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c75215744.descon)
	e2:SetTarget(c75215744.destg)
	e2:SetOperation(c75215744.desop)
	c:RegisterEffect(e2)
end
-- 在超量召唤成功时，检查作为超量素材的怪兽是否包含「舍利军贯」或「鲑鱼子军贯」，并用二进制标志记录在Label中
function c75215744.valcheck(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local flag=0
	if c:GetMaterial():FilterCount(Card.IsCode,nil,24639891)>0 then flag=flag|1 end
	if c:GetMaterial():FilterCount(Card.IsCode,nil,61027400)>0 then flag=flag|2 end
	e:GetLabelObject():SetLabel(flag)
end
-- 检查此卡是否为超量召唤成功
function c75215744.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果①的发动准备，根据超量素材的种类确定是否可以发动，并设置对应的效果分类（抽卡）
function c75215744.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local chk1=e:GetLabel()&1>0
	local chk2=e:GetLabel()&2>0
	-- 检查可行性：若有「舍利军贯」素材则须满足玩家能抽卡，或者有「鲑鱼子军贯」素材
	if chk==0 then return (chk1 and Duel.IsPlayerCanDraw(tp,1) or chk2) end
	if chk1 then
		e:SetCategory(CATEGORY_DRAW)
		-- 设置当前连锁的操作信息为：玩家抽1张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	else
		e:SetCategory(0)
	end
end
-- 效果①的处理：根据超量素材适用对应的效果（抽卡和/或追加攻击次数）
function c75215744.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chk1=e:GetLabel()&1>0
	local chk2=e:GetLabel()&2>0
	if chk1 then
		-- 玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	if chk2 then
		-- 中断当前效果处理，使后续的追加攻击效果与抽卡效果不视为同时处理
		Duel.BreakEffect()
		-- ●「鲑鱼子军贯」：这张卡在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 检查是否为从额外卡组特殊召唤的自己的「军贯」怪兽给与对方战斗伤害
function c75215744.descon(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	return ep~=tp and rc:IsControler(tp) and rc:IsSetCard(0x166) and rc:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果②的发动准备，选择对方场上1张卡作为破坏对象
function c75215744.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 检查对方场上是否存在可以作为对象破坏的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为：破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的处理：破坏作为对象的卡
function c75215744.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

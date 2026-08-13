--CX 機装魔人エンジェネラル
-- 效果：
-- 4星怪兽×3
-- 这张卡超量召唤成功时，可以选择场上守备表示存在的1只怪兽变成表侧攻击表示。此外，这张卡有「机装天使 引擎天兵」在作为超量素材的场合，得到以下效果。
-- ●这张卡给与对方基本分战斗伤害时，把这张卡1个超量素材取除才能发动。给与对方基本分1000分伤害。
function c41309158.initial_effect(c)
	-- 为这张卡添加超量召唤手续：用等级4的怪兽3只作为超量素材来进行超量召唤。
	aux.AddXyzProcedure(c,nil,4,3)
	c:EnableReviveLimit()
	-- 这张卡超量召唤成功时，可以选择场上守备表示存在的1只怪兽变成表侧攻击表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41309158,0))  --"改变表示形式"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c41309158.poscon)
	e1:SetTarget(c41309158.postg)
	e1:SetOperation(c41309158.posop)
	c:RegisterEffect(e1)
	-- 这张卡有「机装天使 引擎天兵」在作为超量素材的场合，得到以下效果。●这张卡给与对方基本分战斗伤害时，把这张卡1个超量素材取除才能发动。给与对方基本分1000分伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41309158,1))  --"LP伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCondition(c41309158.damcon)
	e2:SetCost(c41309158.damcost)
	e2:SetTarget(c41309158.damtg)
	e2:SetOperation(c41309158.damop)
	c:RegisterEffect(e2)
end
-- 第一个诱发效果的发动条件：判定这张卡是否是以超量召唤方式成功召唤（召唤类型为XYZ），只有超量召唤成功时才满足触发条件。
function c41309158.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 第一个效果的发动时目标选择流程：若在连锁处理中对指定卡进行合法性检查，则要求该卡在主要怪兽区且为守备表示；若在发动时检查是否满足条件，则要求场上存在至少1只守备表示怪兽，并提示玩家选择其中1只作为对象。
function c41309158.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsDefensePos() end
	-- 在效果发动时（chk==0）检查双方主要怪兽区是否存在至少1只守备表示怪兽，以此作为该效果能否发动的条件。
	if chk==0 then return Duel.IsExistingTarget(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给操作者显示选择守备表示怪兽的提示消息，提示文本为“请选择守备表示的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEFENSE)  --"请选择守备表示的怪兽"
	-- 让玩家从双方主要怪兽区选择1只守备表示怪兽，并将其登记为当前连锁的效果对象（取对象）。
	Duel.SelectTarget(tp,Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 第一个效果的处理：取得选择的对象怪兽，若该怪兽仍在守备表示且与效果仍有关联，则将其表示形式变为表侧攻击表示。
function c41309158.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的第一个对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsDefensePos() and tc:IsRelateToEffect(e) then
		-- 将对象怪兽的表示形式变更为表侧攻击表示。
		Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
	end
end
-- 第二个诱发效果的发动条件：对方受到战斗伤害（ep~=tp），且这张卡的叠放素材中存在卡号15914410（即「机装天使 引擎天兵」），两者同时满足才能发动。
function c41309158.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,15914410)
end
-- 第二个效果的发动代价：先检查这张卡能否取除1个超量素材作为代价；若可以，则实际取除这张卡的1个超量素材（原因记为REASON_COST）。
function c41309158.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 第二个效果发动时的目标设定：无条件允许发动；将对象玩家设置为对方玩家（1-tp），将伤害参数设置为1000，并向系统登记本次操作是造成1000点效果伤害。
function c41309158.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁处理的对象玩家设置为对方玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁处理的对象参数设置为1000，即要造成的伤害数值。
	Duel.SetTargetParam(1000)
	-- 登记操作信息：本次效果属于CATEGORY_DAMAGE，将对对方玩家造成1000点伤害（对象未在发动时指定，故targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 第二个效果的处理：读取连锁中记录的对象玩家和伤害参数，并给该玩家造成对应的效果伤害。
function c41309158.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出本次效果的对象玩家（伤害对象）和参数（伤害数值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因（REASON_EFFECT）向对象玩家造成参数数值的伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end

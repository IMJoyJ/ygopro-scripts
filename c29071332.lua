--アームズ・エイド
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 1回合1次，自己的主要阶段时可以当作装备卡使用给怪兽装备，或者把装备解除以表侧攻击表示特殊召唤。只在这个效果当作装备卡使用的场合，装备怪兽的攻击力上升1000。此外，装备怪兽战斗破坏怪兽送去墓地时，给与对方基本分破坏的怪兽的原本攻击力数值的伤害。
function c29071332.initial_effect(c)
	-- 为此卡添加同调召唤手续：1只调整 + 1只调整以外的怪兽（满足‘调整＋调整以外的怪兽1只以上’）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 1回合1次，自己的主要阶段时可以当作装备卡使用给怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29071332,0))  --"当作装备卡使用给怪兽装备"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c29071332.eqtg)
	e1:SetOperation(c29071332.eqop)
	c:RegisterEffect(e1)
end
-- 装备效果的发动条件：选择对象时只能选择场上表侧表示怪兽且不能选择自身；并需确认本回合未发动过该效果、魔陷区有空位且场上存在合法对象。
function c29071332.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc~=e:GetHandler() end
	-- 无对象检查：本回合尚未使用过该装备效果（自身没有对应标记），且自己魔陷区有空位。
	if chk==0 then return e:GetHandler():GetFlagEffect(29071332)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且场上存在至少1只除自身以外的表侧表示怪兽可供选择作为装备对象。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 给玩家显示选择装备目标的提示信息（HINTMSG_EQUIP）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从双方场上选择1只表侧表示怪兽（不能选自身）作为装备对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
	-- 向系统登记本次操作是将对象卡装备（CATEGORY_EQUIP），记录目标组 g。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(29071332,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 装备效果处理：先验证自身和对象仍与本效果相关且表侧，若对象不合法则将自身送墓；装备成功后为这张装备卡注册解除装备特殊召唤、攻击力+1000、战斗破坏伤害、装备对象限制四个效果。
function c29071332.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then
		-- 因装备对象不合法，将该装备卡自身以效果原因送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给目标怪兽，若装备不成功则中止处理。
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 或者把装备解除以表侧攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29071332,1))  --"装备解除特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTarget(c29071332.sptg)
	e1:SetOperation(c29071332.spop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	-- 只在这个效果当作装备卡使用的场合，装备怪兽的攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	-- 此外，装备怪兽战斗破坏怪兽送去墓地时，给与对方基本分破坏的怪兽的原本攻击力数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(29071332,2))  --"给予对方伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c29071332.damcon)
	e3:SetTarget(c29071332.damtg)
	e3:SetOperation(c29071332.damop)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3)
	-- 当作装备卡使用给怪兽装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c29071332.eqlimit)
	e4:SetReset(RESET_EVENT+RESETS_STANDARD)
	e4:SetLabelObject(tc)
	c:RegisterEffect(e4)
end
-- 装备限制函数：只有当初发动效果时选择的那只怪兽（LabelObject）才能成为这张装备卡的装备对象。
function c29071332.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 解除装备特殊召唤效果的发动条件：本回合未使用过该效果，自己怪兽区有空位，且自身可以以表侧攻击表示特殊召唤。
function c29071332.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 无对象检查：本回合尚未使用过该特殊召唤效果（无标记），且自己怪兽区有空位。
	if chk==0 then return e:GetHandler():GetFlagEffect(29071332)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_ATTACK) end
	-- 向系统登记本次操作会将此卡特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(29071332,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 解除装备特殊召唤的处理：确认自身仍与本效果关联后，将其特殊召唤到自己场上。
function c29071332.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧攻击表示特殊召唤到自己场上。
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_ATTACK)
end
-- 伤害效果的诱发条件：装备怪兽自身战斗破坏怪兽并将其送去墓地，且被破坏的怪兽是怪兽。
function c29071332.damcon(e,tp,eg,ep,ev,re,r,rp)
	local eqc=e:GetHandler():GetEquipTarget()
	local des=eg:GetFirst()
	return des:IsLocation(LOCATION_GRAVE) and des:GetReasonCard()==eqc and des:IsType(TYPE_MONSTER)
end
-- 伤害效果的目标设定：将被破坏的怪兽与本效果建立关联，将对方设为受伤害玩家，并登记伤害操作信息。
function c29071332.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	eg:GetFirst():CreateEffectRelation(e)
	-- 将本次效果的对象玩家设置为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 向系统登记本次操作会对对方造成伤害（CATEGORY_DAMAGE），伤害数值处理时再确定。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 伤害处理：若被破坏怪兽仍与本效果关联，则取其攻击力数值（若为负则按0），对之前指定的玩家造成伤害。
function c29071332.damop(e,tp,eg,ep,ev,re,r,rp)
	local des=eg:GetFirst()
	-- 取出本连锁中设定的目标玩家（即受伤害玩家）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	if des:IsRelateToEffect(e) then
		local dam=des:GetAttack()
		if dam<0 then dam=0 end
		-- 以效果原因向玩家 p 造成数值为 dam 的伤害。
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end

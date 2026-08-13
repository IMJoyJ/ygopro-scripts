--夢迷枕パラソムニア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的结束阶段才能发动。装备怪兽破坏。
-- ②：装备怪兽被破坏送去墓地让这张卡被送去墓地的场合才能发动。把持有这张卡装备过的怪兽的原本的种族·属性·攻击力的1只「异睡衍生物」（1星·攻?/守0）在自己场上特殊召唤。那之后，这张卡给那衍生物装备。
local s,id,o=GetID()
-- 注册本卡的全部效果：e1为装备魔法发动并装备给对象的激活效果，e2为装备对象限制（可装备怪兽），e3为①的结束阶段破坏装备怪兽的诱发效果，e4为②的装备怪兽被破坏送墓导致本卡送墓时特召「异睡衍生物」并再装备的诱发效果；e3/e4分别以id/id+o做同名1回合1次的计数。
function s.initial_effect(c)
	-- 「装备怪兽」（e1实现装备魔法的发动：选择场上表侧表示怪兽作为装备对象）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- 「装备怪兽」（e2限制为只能装备给怪兽）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ①：自己·对方的结束阶段才能发动。装备怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	-- ②：装备怪兽被破坏送去墓地让这张卡被送去墓地的场合才能发动。把持有这张卡装备过的怪兽的原本的种族·属性·攻击力的1只「异睡衍生物」（1星·攻?/守0）在自己场上特殊召唤。那之后，这张卡给那衍生物装备。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.tkcon)
	e4:SetTarget(s.tktg)
	e4:SetOperation(s.tkop)
	c:RegisterEffect(e4)
end
-- 目标选择函数：发动时先确认双方场上存在可选的表侧表示怪兽；提示玩家选择1只，将其登记为取对象目标，并设置此卡装备给对象的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查是否存在至少1只以玩家视角位于双方怪兽区、可被取对象且表侧表示的怪兽，作为发动条件。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示‘请选择要装备的卡’的选卡提示，将HINTMSG_EQUIP写入选择缓存供后续选择使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从双方怪兽区选择1只表侧表示怪兽，设为当前连锁的效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 登记此次处理将把e:GetHandler()（这张装备卡）装备给对象的信息（CATEGORY_EQUIP），供其他卡的判定使用。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：取出对象怪兽；若此卡仍与效果关联、对象仍与效果关联且表侧表示，则将此卡装备给对象，并把回合计数器归零。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取出当前连锁记录的1只对象（装备目标）怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为玩家tp的装备魔法卡，装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
		e:GetHandler():SetTurnCounter(0)
	end
end
-- ①的发动条件与对象登记：取得此卡当前装备的怪兽；若不存在则不能发动；若存在则把那只装备怪兽与效果建立联系，并登记为破坏对象。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	if chk==0 then return ec end
	ec:CreateEffectRelation(e)
	-- 登记将破坏装备怪兽的信息（CATEGORY_DESTROY），供连锁相关判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,ec,1,0,0)
end
-- ①效果处理：取得当前装备怪兽；若它仍与效果关联，则将其破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if ec and ec:IsRelateToEffect(e) then
		-- 以效果原因REASON_EFFECT把装备怪兽破坏。
		Duel.Destroy(ec,REASON_EFFECT)
	end
end
-- ②的发动条件：此卡因装备怪兽被破坏并送去墓地而失去装备对象（REASON_LOST_TARGET）被送去墓地，且原装备怪兽被破坏后位于墓地。
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return ec and c:IsReason(REASON_LOST_TARGET) and ec:IsReason(REASON_DESTROY) and ec:IsLocation(LOCATION_GRAVE)
end
-- ②的目标/合法检查：取得原装备怪兽的原本种族/原本属性/基础攻击力；确认怪兽区与魔陷区都有空位且能特召对应的「异睡衍生物」，然后把数值存入效果标签并登记特召衍生物与墓地卡片离场的信息。
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	local race=ec:GetOriginalRace()
	local attr=ec:GetOriginalAttribute()
	local atk=ec:GetBaseAttack()
	-- 检查我方场上是否同时有可用的主要怪兽区空格和魔陷区空格（分别用于特召衍生物和装备此卡）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 继续检查能否以记录的原本种族、属性、攻击力，特殊召唤1只1星·攻击力?/守备力0的「异睡衍生物」衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,atk,0,1,race,attr) end
	e:SetLabel(race,attr,atk)
	-- 登记本次处理将生成衍生物（CATEGORY_TOKEN）。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 登记本次处理将特殊召唤怪兽（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 登记此卡将从墓地离开并装备到衍生物上的信息（CATEGORY_LEAVE_GRAVE）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- ②效果处理：若仍满足条件，则生成「异睡衍生物」，用三个效果把它的种族、属性、基础攻击力改成记录的原本数值，并将其表侧攻击表示特殊召唤；之后若此卡仍关联，则先BreakEffect再装备给该衍生物。
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local race,attr,atk=e:GetLabel()
	-- 再次确认我方主要怪兽区仍有空格。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 再次确认能够特殊召唤具有对应原本种族/属性/攻击力的「异睡衍生物」衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,atk,0,1,race,attr) then
		-- 生成1只「异睡衍生物」衍生物（token卡号id+o）到tp方场上。
		local token=Duel.CreateToken(tp,id+o)
		-- 「持有这张卡装备过的怪兽的原本的种族·属性·攻击力」
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(race)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		token:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e2:SetValue(attr)
		token:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_SET_BASE_ATTACK)
		e3:SetValue(atk)
		token:RegisterEffect(e3)
		-- 将生成的衍生物以表侧攻击表示特殊召唤到tp场上。
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		if c:IsRelateToEffect(e) then
			-- 中断当前效果处理，使后续装备动作与特殊召唤不同步进行，以符合‘那之后’的时点处理。
			Duel.BreakEffect()
			-- 把这张卡（从墓地）装备给刚特殊召唤的「异睡衍生物」衍生物。
			Duel.Equip(tp,c,token)
		end
	end
end

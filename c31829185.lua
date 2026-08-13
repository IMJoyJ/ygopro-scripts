--ダーク・ネクロフィア
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把3只恶魔族怪兽除外的场合可以特殊召唤。
-- ①：怪兽区域的这张卡被对方破坏送去墓地的回合的结束阶段，以对方场上1只表侧表示怪兽为对象发动。墓地的这张卡当作装备卡使用给那只对方怪兽装备。
-- ②：这张卡的效果让这张卡装备中的场合，得到装备怪兽的控制权。
function c31829185.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从自己墓地把3只恶魔族怪兽除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c31829185.spcon)
	e1:SetTarget(c31829185.sptg)
	e1:SetOperation(c31829185.spop)
	c:RegisterEffect(e1)
	-- ①：怪兽区域的这张卡被对方破坏送去墓地的回合的结束阶段
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(c31829185.tgop)
	c:RegisterEffect(e2)
	-- ①：怪兽区域的这张卡被对方破坏送去墓地的回合的结束阶段，以对方场上1只表侧表示怪兽为对象发动。墓地的这张卡当作装备卡使用给那只对方怪兽装备。②：这张卡的效果让这张卡装备中的场合，得到装备怪兽的控制权。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1)
	e3:SetCondition(c31829185.eqcon)
	e3:SetTarget(c31829185.eqtg)
	e3:SetOperation(c31829185.eqop)
	c:RegisterEffect(e3)
end
-- 筛选可作为特殊召唤代价的恶魔族怪兽：必须是恶魔族且能够从墓地除外作为代价。
function c31829185.spfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则条件：当c为nil时默认允许；实际召唤时要求自己怪兽区有空位，且自己墓地存在至少3只符合条件的恶魔族怪兽。
function c31829185.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己主要怪兽区是否有可用空位，保证特殊召唤能够进行。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少3只满足spfilter（恶魔族且可作为代价除外）的怪兽。
		and Duel.IsExistingMatchingCard(c31829185.spfilter,tp,LOCATION_GRAVE,0,3,nil)
end
-- 为特殊召唤手续选择3只除外的恶魔族怪兽：从墓地候选组中要求玩家选3张，保存选择结果并返回true；若取消则返回false。
function c31829185.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有符合条件的恶魔族怪兽，组成可选候选组。
	local g=Duel.GetMatchingGroup(c31829185.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 向玩家发送“请选择要除外的卡”的提示消息，用于选择除外代价卡的交互。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,3,3,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤代价：将之前选择的3只恶魔族怪兽表侧表示除外，并清理临时保留的选择组。
function c31829185.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以表侧表示将那组选择的怪兽除外，除外职因为特殊召唤（作为特殊召唤手续的代价）。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 记录“被对方破坏送去墓地”这一事实：若此卡从自己怪兽区域被对方破坏并送墓，则在结束阶段前持有flag标记，作为①效果的发动条件。
function c31829185.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and rp==1-tp and bit.band(r,REASON_DESTROY)~=0 then
		c:RegisterFlagEffect(31829185,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 判定①效果是否可在结束阶段发动：该卡在墓地且持有“被对方破坏送去墓地”的flag标记（即满足“被对方破坏送去墓地的回合的结束阶段”）。
function c31829185.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(31829185)>0
end
-- ①效果的发动目标处理：选择对方场上1只表侧表示怪兽作为装备/控制权夺取对象；并设置控制权改变、装备、离开墓地等操作信息供连锁判定使用。
function c31829185.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return true end
	-- 向玩家发送“请选择要改变控制权的怪兽”的提示消息（实际选择装备对象，但后续会获得其控制权）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 从对方场上选择1只表侧怪兽作为效果对象，并登记为当前连锁的取对象目标。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本连锁将改变1只怪兽的控制权（用于向系统声明该效果涉及控制权夺取，便于相关卡片响应）。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	-- 设置操作信息：本连锁将把墓地的这张卡作为装备卡装备（声明装备行为），涉及卡片为尼可罗菲娅自身。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置操作信息：本连锁会让墓地中的卡片离开墓地，使影响墓地离场的效果（如王家长眠之谷）能够正确响应。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 装备限制判断：这张装备卡只能装备给发动时选择的那只对象怪兽（e的所有者），防止之后被其他效果转移到其他怪兽身上。
function c31829185.eqlimit(e,c)
	return e:GetOwner()==c
end
-- ①效果处理：在魔陷区有空位的前提下，将墓地的这张卡装备给对象怪兽，并为它添加“只能装备给该对象”的限制；随后通过EFFECT_SET_CONTROL效果让该卡装备期间获得装备怪兽的控制权，实现②效果。
function c31829185.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己魔陷区是否有可用空位；若没有空位则无法装备，效果处理中止。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 取得发动时选择的目标怪兽（装备对象）。
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 把墓地的这张卡作为装备卡装备给目标怪兽，装备控制者为我方。
		Duel.Equip(tp,c,tc)
		-- 墓地的这张卡当作装备卡使用给那只对方怪兽装备。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c31829185.eqlimit)
		c:RegisterEffect(e1)
		-- ②：这张卡的效果让这张卡装备中的场合，得到装备怪兽的控制权。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_SET_CONTROL)
		e2:SetValue(tp)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		c:RegisterEffect(e2)
	end
end

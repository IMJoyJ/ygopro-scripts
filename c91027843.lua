--海晶乙女の闘海
-- 效果：
-- ①：自己场上的「海晶少女」怪兽的攻击力上升200，再上升装备的「海晶少女」卡数量×600。
-- ②：用「海晶少女 水晶心」为素材作连接召唤的额外怪兽区域的自己怪兽不受对方的效果影响。
-- ③：自己在额外怪兽区域把「海晶少女」连接怪兽连接召唤时才能发动。从自己墓地选最多3只「海晶少女」连接怪兽给那只连接召唤的怪兽当作装备卡使用来装备（同名卡最多1张）。
function c91027843.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的「海晶少女」怪兽的攻击力上升200，再上升装备的「海晶少女」卡数量×600。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果影响的对象为自己场上的「海晶少女」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x12b))
	e2:SetValue(c91027843.atkval)
	c:RegisterEffect(e2)
	-- ②：用「海晶少女 水晶心」为素材作连接召唤的额外怪兽区域的自己怪兽不受对方的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c91027843.immtg)
	e3:SetValue(c91027843.efilter)
	c:RegisterEffect(e3)
	-- ③：自己在额外怪兽区域把「海晶少女」连接怪兽连接召唤时才能发动。从自己墓地选最多3只「海晶少女」连接怪兽给那只连接召唤的怪兽当作装备卡使用来装备（同名卡最多1张）。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(91027843,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCondition(c91027843.eqcon)
	e4:SetTarget(c91027843.eqtg)
	e4:SetOperation(c91027843.eqop)
	c:RegisterEffect(e4)
end
-- 计算攻击力上升值：基础200点，加上装备的「海晶少女」卡数量×600点
function c91027843.atkval(e,c)
	return 200+c:GetEquipGroup():FilterCount(Card.IsSetCard,nil,0x12b)*600
end
-- 过滤不受效果影响的怪兽：处于额外怪兽区域、是连接召唤的怪兽，且具有由「海晶少女 水晶心」作为素材赋予的特定标记
function c91027843.immtg(e,c)
	return c:GetSequence()>4 and c:IsSummonType(SUMMON_TYPE_LINK) and c:GetFlagEffect(91027843)~=0
end
-- 过滤不受影响的效果：由对方玩家拥有的卡片发动的效果
function c91027843.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
-- 过滤触发条件中的怪兽：由自己连接召唤到额外怪兽区域的「海晶少女」连接怪兽
function c91027843.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:GetSequence()>4 and c:IsSetCard(0x12b) and c:IsType(TYPE_LINK) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 检查是否满足发动条件：自己连接召唤了「海晶少女」连接怪兽到额外怪兽区域
function c91027843.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c91027843.cfilter,1,nil,tp)
end
-- 过滤可以作为装备卡的墓地怪兽：墓地的「海晶少女」连接怪兽且不能是无法放置在魔陷区的卡
function c91027843.eqfilter(c)
	return c:IsSetCard(0x12b) and c:IsType(TYPE_LINK) and not c:IsForbidden()
end
-- 效果发动的对象与可行性检查：检查魔陷区是否有空位，以及墓地是否存在可装备的怪兽
function c91027843.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的魔陷区空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的「海晶少女」连接怪兽
		and Duel.IsExistingMatchingCard(c91027843.eqfilter,tp,LOCATION_GRAVE,0,1,nil) end
	eg:GetFirst():CreateEffectRelation(e)
	-- 设置连锁操作信息：涉及卡片离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理：从墓地选择最多3张卡名不同的「海晶少女」连接怪兽，作为装备卡装备给该连接召唤的怪兽
function c91027843.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=eg:GetFirst()
	-- 计算可以装备的最大卡片数量（魔陷区空位数与3的较小值）
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_SZONE)),3)
	-- 获取自己墓地中所有满足条件且不受「王家之谷」影响的「海晶少女」连接怪兽
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c91027843.eqfilter),tp,LOCATION_GRAVE,0,nil)
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) or ft<=0 or g:GetCount()<=0 then return end
	-- 提示玩家选择要装备的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择1到ft张卡名互不相同的怪兽卡
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
	if sg and sg:GetCount()>0 then
		local sc=sg:GetFirst()
		while sc do
			-- 将选中的怪兽作为装备卡装备给连接召唤的怪兽（分步进行，不立即触发装备完成时点）
			Duel.Equip(tp,sc,tc,false,true)
			-- 当作装备卡使用来装备
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetLabelObject(tc)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c91027843.eqlimit)
			sc:RegisterEffect(e1)
			sc=sg:GetNext()
		end
		-- 触发装备完成的时点
		Duel.EquipComplete()
	end
end
-- 限制装备卡只能装备给该特定的连接怪兽
function c91027843.eqlimit(e,c)
	return e:GetLabelObject()==c
end

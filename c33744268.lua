--Z－ジリオン・キャタピラー
-- 效果：
-- ①：这张卡特殊召唤的场合才能发动。自己的除外状态的1只机械族·光属性·4星怪兽当作装备魔法卡使用给这张卡装备。这个回合，自己不是光属性怪兽不能从额外卡组特殊召唤。
-- ②：1回合1次，可以把1个以下效果发动。
-- ●以自己场上1只机械族怪兽为对象，把这张卡当作装备魔法卡使用来装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备状态的这张卡特殊召唤。
local s,id,o=GetID()
-- 注册Z-无穷履带的初始效果：调用aux.EnableUnionAttribute为其附加同盟通用效果，并创建①的特殊召唤成功时触发效果e1，设置其描述、分类、类型、触发事件、延迟特性、发动目标筛选与处理函数后注册到卡上。
function s.initial_effect(c)
	-- 为Z-无穷履带注册同盟怪兽通用效果（主要阶段手牌/场上装备、装备怪兽代破、装备数量限制、解除装备特殊召唤等），s.filter用于限定可装备的对象为机械族怪兽。
	aux.EnableUnionAttribute(c,s.filter)
	-- 对应效果原文：“①：这张卡特殊召唤的场合才能发动。自己的除外状态的1只机械族·光属性·4星怪兽当作装备魔法卡使用给这张卡装备。” 此处创建并注册该特殊召唤诱发效果。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"装备效果"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
end
-- 定义同盟/装备对象的基础过滤函数：仅允许选择机械族怪兽作为装备对象。
function s.filter(c)
	return c:IsRace(RACE_MACHINE)
end
-- 定义选择除外区装备对象的过滤条件：需为表侧表示的机械族、光属性、4星怪兽，且满足场上唯一性、不是禁止卡，才能被选为装备卡。
function s.eqfilter(c,tc,tp)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(4) and c:IsFaceupEx()
		and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- 效果发动条件判定：在自己除外区存在1只符合条件的怪兽，且自己魔陷区有空位时，该效果才满足发动条件。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己的除外区是否存在至少1只满足s.eqfilter条件（机械族·光属性·4星）的怪兽，作为效果发动的必要条件之一。
	if chk==0 then return Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_REMOVED,0,1,nil,c,tp)
		-- 检查自己魔陷区是否有可用的空位，以放置即将装备的装备魔法卡。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	-- 向发动玩家tp显示选择提示“请选择表侧表示的卡”（实际用于选择除外区的表侧怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 登记本次连锁的操作信息：声明本效果将进行“装备”操作，目标所在位置为除外区，预计处理数量为1张，供其他效果联动检测。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_REMOVED)
end
-- 处理效果①的装备与自肃：若发动卡仍在场且表侧，且有魔陷空位，则从除外区选1张符合条件的机械族光属性4星怪兽装备给它；随后给装备怪兽注册只能装备给本卡的装备限制；最后为tp玩家注册本回合“不是光属性怪兽不能从额外卡组特殊召唤”的自肃效果。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定装备处理条件：效果发动者Z-无穷履带仍与当前效果关联且表侧表示，且自己魔陷区仍有空位，才继续执行装备。
	if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 向玩家tp显示选择提示“请选择要装备的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从自己除外区选择1张满足s.eqfilter的机械族·光属性·4星怪兽，作为要装备的卡片。
		local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_REMOVED,0,1,1,nil,c,tp)
		local sc=g:GetFirst()
		-- 尝试将选择的怪兽sc作为装备卡由tp装备给Z-无穷履带，若装备成功则继续注册限制效果。
		if sc and Duel.Equip(tp,sc,c) then
			-- 对应效果原文中的“当作装备魔法卡使用给这张卡装备”：为成功装备的怪兽卡设置装备限制，使其只能装备给Z-无穷履带。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetLabelObject(c)
			e1:SetValue(s.eqlimit)
			sc:RegisterEffect(e1)
		end
	end
	-- 对应效果原文：“这个回合，自己不是光属性怪兽不能从额外卡组特殊召唤。” 此处为tp玩家注册该自肃，并定义了s.splimit与s.eqlimit辅助函数。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果e1作为影响玩家tp的领域效果注册到场上，使其在结束阶段前持续生效。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的判定函数：若特殊召唤的怪兽不在额外卡组（LOCATION_EXTRA）且不是光属性，则不允许特殊召唤。
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLocation(LOCATION_EXTRA)
end
-- 装备限制判定函数：只有被判定对象c与创建该效果时记录的LabelObject（即Z-无穷履带）相同，才允许作为装备对象。
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end

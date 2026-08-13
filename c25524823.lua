--墓守の審神者
-- 效果：
-- 这张卡也能把3只怪兽或者1只「守墓」怪兽解放表侧表示上级召唤。
-- ①：这张卡上级召唤成功时，可以从以下效果选择最多有为这张卡的上级召唤而解放的「守墓」怪兽的数量发动。
-- ●这张卡的攻击力上升因为这张卡的上级召唤而解放的怪兽的等级合计×100。
-- ●对方场上的里侧表示怪兽全部破坏。
-- ●对方场上的全部怪兽的攻击力·守备力下降2000。
function c25524823.initial_effect(c)
	-- 这张卡也能把3只怪兽解放表侧表示上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25524823,0))  --"解放3只怪兽召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c25524823.ttcon)
	e1:SetOperation(c25524823.ttop)
	e1:SetValue(SUMMON_TYPE_ADVANCE+SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 或者1只「守墓」怪兽解放表侧表示上级召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25524823,1))  --"解放1只名字带有「守墓」的怪兽召唤"
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(c25524823.otcon)
	e2:SetOperation(c25524823.otop)
	e2:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e2)
	-- ①：这张卡上级召唤成功时，可以从以下效果选择最多有为这张卡的上级召唤而解放的「守墓」怪兽的数量发动。●这张卡的攻击力上升因为这张卡的上级召唤而解放的怪兽的等级合计×100。●对方场上的里侧表示怪兽全部破坏。●对方场上的全部怪兽的攻击力·守备力下降2000。
	local e3=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25524823,6))  --"效果发动"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(c25524823.condition)
	e3:SetTarget(c25524823.target)
	e3:SetOperation(c25524823.operation)
	c:RegisterEffect(e3)
	-- 记录这次上级召唤解放的「守墓」怪兽数量和全部解放怪兽的等级合计，对应①效果中‘最多有为这张卡的上级召唤而解放的「守墓」怪兽的数量’与‘因为这张卡的上级召唤而解放的怪兽的等级合计×100’所需的信息。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c25524823.valcheck)
	c:RegisterEffect(e4)
	e3:SetLabelObject(e4)
	e4:SetLabelObject(e3)
end
-- 召唤规则条件：若 c 为空则规则可用；否则要求所需解放数不超过3，且场上存在可解放的3只怪兽。
function c25524823.ttcon(e,c,minc)
	if c==nil then return true end
	-- 判断所需解放数不超过3，且场上存在3只可作为上级召唤祭品的怪兽。
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 执行解放3只怪兽的上级召唤手续：提示玩家选择祭品，选择3只怪兽设为素材并以召唤·素材理由解放。
function c25524823.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 提示玩家选择要解放的卡（HINTMSG_RELEASE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从场上选择3只怪兽作为这次上级召唤的祭品，返回选中组 g。
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 将选中的祭品以召唤·素材（REASON_SUMMON+REASON_MATERIAL）的理由解放。
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 筛选可作为祭品的「守墓」怪兽：必须带有「守墓」字段，且为自身场上的怪兽或对方场上表侧表示的怪兽（里侧表示无法被确认/选择）。
function c25524823.otfilter(c,tp)
	return c:IsSetCard(0x2e) and (c:IsControler(tp) or c:IsFaceup())
end
-- 该召唤规则的条件：这张卡等级须在7以上、所需解放数不超过1，且候选组中存在1只符合条件的「守墓」怪兽可作为祭品。
function c25524823.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取所有可作为祭品的「守墓」怪兽候选组（双方怪兽区中满足 otfilter 的怪兽）。
	local mg=Duel.GetMatchingGroup(c25524823.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 最终判定：这张卡等级≥7、所需解放数≤1，并且可从候选组中选出1只「守墓」怪兽作为祭品。
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 执行解放1只「守墓」怪兽的上级召唤手续：从候选组中选择1只怪兽，设置为素材并解放。
function c25524823.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取可作为祭品的「守墓」怪兽候选组（双方怪兽区中满足 otfilter 的怪兽）。
	local mg=Duel.GetMatchingGroup(c25524823.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家从候选组中选择1只「守墓」怪兽作为这次上级召唤的祭品。
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选中的1只「守墓」怪兽以召唤·素材（REASON_SUMMON+REASON_MATERIAL）的理由解放。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 素材信息检查：统计这次上级召唤的素材中「守墓」怪兽的数量以及全部素材的等级合计，分别存入 e 和关联效果的 Label，供①效果的选择次数与攻击力上升量使用。
function c25524823.valcheck(e,c)
	local g=c:GetMaterial()
	local ct=g:FilterCount(Card.IsSetCard,nil,0x2e)
	local lv=0
	local tc=g:GetFirst()
	while tc do
		lv=lv+tc:GetLevel()
		tc=g:GetNext()
	end
	e:SetLabel(lv)
	e:GetLabelObject():SetLabel(ct)
end
-- 诱发效果的发动条件：这张卡以表侧表示上级召唤成功（召唤类型为 ADVANCE）。
function c25524823.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 过滤函数：判断怪兽是否为里侧表示，用于选取对方场上里侧表示怪兽。
function c25524823.filter(c)
	return c:IsFacedown()
end
-- ①效果的发动时处理：在 chk==0 时检查是否满足发动条件（解放过守墓且至少一个选项可用）；在发动时根据可用选项让玩家循环选择最多 ct 个效果，并用位标记 sel 保存选择；若选到破坏效果，则登记破坏操作信息。
function c25524823.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	local b1=e:GetLabelObject():GetLabel()>0
	-- 检查对方场上是否存在至少1只里侧表示怪兽，决定‘对方场上的里侧表示怪兽全部破坏’选项是否可用。
	local b2=Duel.IsExistingMatchingCard(c25524823.filter,tp,0,LOCATION_MZONE,1,nil)
	-- 检查对方场上是否存在至少1只表侧表示怪兽，决定‘对方场上的全部怪兽的攻击力·守备力下降2000’选项是否可用。
	local b3=Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then return ct>0 and (b1 or b2 or b3) end
	local sel=0
	local off=0
	repeat
		local ops={}
		local opval={}
		off=1
		if b1 then
			ops[off]=aux.Stringid(25524823,2)  --"这张卡的攻击力上升"
			opval[off-1]=1
			off=off+1
		end
		if b2 then
			ops[off]=aux.Stringid(25524823,3)  --"对方场上盖放的怪兽全部破坏"
			opval[off-1]=2
			off=off+1
		end
		if b3 then
			ops[off]=aux.Stringid(25524823,4)  --"对方场上的全部怪兽的攻击力·守备力下降"
			opval[off-1]=3
			off=off+1
		end
		-- 将当前所有可选效果以选项形式展示给玩家，并返回玩家所选项的索引（从0开始）。
		local op=Duel.SelectOption(tp,table.unpack(ops))
		if opval[op]==1 then
			sel=sel+1
			b1=false
		elseif opval[op]==2 then
			sel=sel+2
			b2=false
		else
			sel=sel+4
			b3=false
		end
		ct=ct-1
	-- 循环结束条件：剩余可选次数为0、或剩余可用选项不足2个、或玩家选择不再继续选择效果。
	until ct==0 or off<3 or not Duel.SelectYesNo(tp,aux.Stringid(25524823,5))  --"是否要继续选择效果发动？"
	e:SetLabel(sel)
	if bit.band(sel,2)~=0 then
		-- 获取对方场上所有里侧表示怪兽组，用于设置破坏效果的操作信息。
		local g=Duel.GetMatchingGroup(c25524823.filter,tp,0,LOCATION_MZONE,nil)
		-- 登记当前连锁的操作信息：本效果将破坏 g 中全部里侧表示怪兽，破坏数量为 g:GetCount()。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	end
end
-- ①效果处理：根据 target 阶段保存的位标记 sel，按顺序执行选中的效果——攻击力上升、破坏对方里侧表示怪兽、对方全场攻守下降2000；在破坏和攻守下降前各调用一次 Duel.BreakEffect 以错开时点。
function c25524823.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sel=e:GetLabel()
	if bit.band(sel,1)~=0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		local lv=e:GetLabelObject():GetLabel()
		-- ●这张卡的攻击力上升因为这张卡的上级召唤而解放的怪兽的等级合计×100。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(lv*100)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
	if bit.band(sel,2)~=0 then
		-- 获取对方场上所有里侧表示怪兽组，用于执行破坏效果。
		local g=Duel.GetMatchingGroup(c25524823.filter,tp,0,LOCATION_MZONE,nil)
		if g:GetCount()>0 then
			-- 中断当前效果链，使此后的破坏/下降效果视为不同时处理（错开时点）。
			Duel.BreakEffect()
			-- 以效果原因破坏 g 中的全部里侧表示怪兽，即执行‘对方场上的里侧表示怪兽全部破坏’。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
	if bit.band(sel,4)~=0 then
		-- 获取对方场上所有表侧表示怪兽，用于执行攻击力·守备力下降效果。
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		local tc=g:GetFirst()
		if tc then
			-- 中断当前效果链，使攻守下降效果与前面的破坏效果不在同一时点处理。
			Duel.BreakEffect()
			while tc do
				-- ●对方场上的全部怪兽的攻击力·守备力下降2000。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(-2000)
				tc:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_UPDATE_DEFENSE)
				tc:RegisterEffect(e2)
				tc=g:GetNext()
			end
		end
	end
end

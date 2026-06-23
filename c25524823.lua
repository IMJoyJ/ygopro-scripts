--墓守の審神者
-- 效果：
-- 这张卡也能把3只怪兽或者1只「守墓」怪兽解放表侧表示上级召唤。
-- ①：这张卡上级召唤成功时，可以从以下效果选择最多有为这张卡的上级召唤而解放的「守墓」怪兽的数量发动。
-- ●这张卡的攻击力上升因为这张卡的上级召唤而解放的怪兽的等级合计×100。
-- ●对方场上的里侧表示怪兽全部破坏。
-- ●对方场上的全部怪兽的攻击力·守备力下降2000。
function c25524823.initial_effect(c)
	-- 创建一个上级召唤效果，允许解放3只怪兽进行召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25524823,0))  --"解放3只怪兽召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c25524823.ttcon)
	e1:SetOperation(c25524823.ttop)
	e1:SetValue(SUMMON_TYPE_ADVANCE+SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 创建一个上级召唤效果，允许解放1只「守墓」怪兽进行召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25524823,1))  --"解放1只名字带有「守墓」的怪兽召唤"
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(c25524823.otcon)
	e2:SetOperation(c25524823.otop)
	e2:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e2)
	-- 创建上级召唤成功时的诱发效果，可以选择发动以下效果：这张卡的攻击力上升、对方场上的里侧表示怪兽全部破坏、对方场上的全部怪兽的攻击力·守备力下降2000
	local e3=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25524823,6))  --"效果发动"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(c25524823.condition)
	e3:SetTarget(c25524823.target)
	e3:SetOperation(c25524823.operation)
	c:RegisterEffect(e3)
	-- 设置素材检查效果，用于记录上级召唤时解放的怪兽等级总和与「守墓」怪兽数量
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c25524823.valcheck)
	c:RegisterEffect(e4)
	e3:SetLabelObject(e4)
	e4:SetLabelObject(e3)
end
-- 判断是否满足上级召唤条件：解放3只怪兽
function c25524823.ttcon(e,c,minc)
	if c==nil then return true end
	-- 判断是否满足上级召唤条件：解放3只怪兽
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 上级召唤时执行的操作：选择并解放3只怪兽
function c25524823.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择3只怪兽作为祭品
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 将选择的怪兽解放
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 过滤「守墓」怪兽的函数
function c25524823.otfilter(c,tp)
	return c:IsSetCard(0x2e) and (c:IsControler(tp) or c:IsFaceup())
end
-- 判断是否满足上级召唤条件：解放1只「守墓」怪兽
function c25524823.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上所有「守墓」怪兽的集合
	local mg=Duel.GetMatchingGroup(c25524823.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判断是否满足上级召唤条件：解放1只「守墓」怪兽
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 上级召唤时执行的操作：选择并解放1只「守墓」怪兽
function c25524823.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上所有「守墓」怪兽的集合
	local mg=Duel.GetMatchingGroup(c25524823.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 选择1只「守墓」怪兽作为祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选择的怪兽解放
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 检查上级召唤时解放的怪兽等级总和与「守墓」怪兽数量
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
-- 判断上级召唤是否成功
function c25524823.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 过滤里侧表示怪兽的函数
function c25524823.filter(c)
	return c:IsFacedown()
end
-- 设置上级召唤成功时的效果选择与处理
function c25524823.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	local b1=e:GetLabelObject():GetLabel()>0
	-- 检查对方场上是否存在里侧表示怪兽
	local b2=Duel.IsExistingMatchingCard(c25524823.filter,tp,0,LOCATION_MZONE,1,nil)
	-- 检查对方场上是否存在表侧表示怪兽
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
		-- 选择发动的效果
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
	-- 判断是否继续选择效果发动
	until ct==0 or off<3 or not Duel.SelectYesNo(tp,aux.Stringid(25524823,5))  --"是否要继续选择效果发动？"
	e:SetLabel(sel)
	if bit.band(sel,2)~=0 then
		-- 获取对方场上的里侧表示怪兽集合
		local g=Duel.GetMatchingGroup(c25524823.filter,tp,0,LOCATION_MZONE,nil)
		-- 设置破坏效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	end
end
-- 执行上级召唤成功时选择的效果
function c25524823.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sel=e:GetLabel()
	if bit.band(sel,1)~=0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		local lv=e:GetLabelObject():GetLabel()
		-- 使这张卡的攻击力上升因上级召唤而解放的怪兽等级总和×100
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(lv*100)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
	if bit.band(sel,2)~=0 then
		-- 获取对方场上的里侧表示怪兽集合
		local g=Duel.GetMatchingGroup(c25524823.filter,tp,0,LOCATION_MZONE,nil)
		if g:GetCount()>0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 破坏对方场上的里侧表示怪兽
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
	if bit.band(sel,4)~=0 then
		-- 获取对方场上的表侧表示怪兽集合
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		local tc=g:GetFirst()
		if tc then
			-- 中断当前效果处理
			Duel.BreakEffect()
			while tc do
				-- 使对方场上的全部怪兽的攻击力下降2000
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

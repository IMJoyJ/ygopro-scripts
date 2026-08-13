--凍氷帝メビウス
-- 效果：
-- 这张卡可以把1只上级召唤的怪兽解放作上级召唤。这张卡上级召唤成功时，可以选择场上最多3张魔法·陷阱卡破坏。这张卡把水属性怪兽解放作上级召唤成功的场合，那个时候的效果加上以下效果。
-- ●对方不能对应这个效果的发动把选择的卡发动。
function c23689697.initial_effect(c)
	-- 这张卡可以把1只上级召唤的怪兽解放作上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23689697,0))  --"把1只上级召唤的怪兽解放进行上级召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c23689697.otcon)
	e1:SetOperation(c23689697.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	-- 这张卡上级召唤成功时，可以选择场上最多3张魔法·陷阱卡破坏。这张卡把水属性怪兽解放作上级召唤成功的场合，那个时候的效果加上以下效果。●对方不能对应这个效果的发动把选择的卡发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(23689697,1))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(c23689697.descon)
	e3:SetTarget(c23689697.destg)
	e3:SetOperation(c23689697.desop)
	c:RegisterEffect(e3)
	-- 这张卡把水属性怪兽解放作上级召唤成功的场合，那个时候的效果加上以下效果。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c23689697.valcheck)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
-- 筛选出以上级召唤方式成功召唤过的怪兽，作为可供解放的素材候选。
function c23689697.otfilter(c)
	return c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 召唤规则条件：当c为nil时表示该召唤规则效果存在；否则需要这张卡为7星以上、所需解放数不超过1，且场上存在可用的上级召唤过的怪兽作为祭品。
function c23689697.otcon(e,c,minc)
	if c==nil then return true end
	-- 获取双方场上所有以上级召唤方式召唤过的怪兽，组成可选的解放祭品候选组。
	local mg=Duel.GetMatchingGroup(c23689697.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 判定该卡等级是否在7以上、所需解放数是否不超过1，以及是否存在可用祭品。
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 执行上级召唤手续：选择1只上级召唤过的怪兽作为解放祭品，记录素材并解放，完成以1只怪兽解放的上级召唤。
function c23689697.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取双方场上所有以上级召唤方式召唤过的怪兽，作为这次召唤可选的祭品范围。
	local mg=Duel.GetMatchingGroup(c23689697.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 玩家从候选祭品组中选择1只怪兽作为这次上级召唤的解放素材。
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选择的怪兽解放，原因设定为召唤和作为素材（REASON_SUMMON+REASON_MATERIAL）。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 诱发条件：这张卡是以表侧表示的上级召唤方式成功召唤。
function c23689697.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 筛选出卡类型为魔法·陷阱卡的卡，作为可破坏对象。
function c23689697.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 选择1~3张魔法·陷阱卡为破坏对象，并写入破坏操作信息；若本次解放过水属性怪兽，则追加设置连锁限制。
function c23689697.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c23689697.filter(chkc) end
	-- 检查场上是否存在至少1张可以成为对象的魔法·陷阱卡，作为发动合法性的条件。
	if chk==0 then return Duel.IsExistingTarget(c23689697.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家展示选择提示，要求选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择1~3张魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,c23689697.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,3,nil)
	-- 将破坏的对象组及数量写入连锁操作信息，供处理及后续检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	if e:GetLabel()==1 then
		-- 设置连锁限制：对方不能对应这个效果的发动把被选择的魔法·陷阱卡发动。
		Duel.SetChainLimit(c23689697.chlimit)
	end
end
-- 连锁限制函数：若尝试连锁的是冻冰帝的操控者则允许；若对方要发动的卡不属于被选择的破坏对象则允许；否则禁止。
function c23689697.chlimit(e,ep,tp)
	-- 取得当前连锁中记录的对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return tp==ep or not g:IsContains(e:GetHandler())
end
-- 效果处理：取得对象卡组，筛选出仍与效果关联的卡，将它们全部破坏。
function c23689697.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 以效果原因将筛选出的对象卡破坏。
	Duel.Destroy(sg,REASON_EFFECT)
end
-- 素材检查：若这次上级召唤使用的解放素材中存在水属性怪兽，则将破坏效果的标签设为1，否则设为0；该标签用于在破坏效果中追加“对方不能对应发动”的限制。
function c23689697.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WATER) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end

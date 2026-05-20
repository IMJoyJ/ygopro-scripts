--古の呪文
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的卡组·墓地把1只「太阳神之翼神龙」加入手卡，这个回合自己在通常召唤外加上只有1次，自己主要阶段可以上级召唤。
-- ②：把墓地的这张卡除外才能发动。发动后，这个回合中自己把「太阳神之翼神龙」上级召唤的场合，那个原本的攻击力·守备力变成因为那次上级召唤而解放的怪兽的原本的攻击力·守备力各自合计数值。
function c78665705.initial_effect(c)
	-- 记录这张卡记载了「太阳神之翼神龙」的卡名。
	aux.AddCodeList(c,10000010)
	-- ①：从自己的卡组·墓地把1只「太阳神之翼神龙」加入手卡，这个回合自己在通常召唤外加上只有1次，自己主要阶段可以上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78665705,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,78665705+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c78665705.target)
	e1:SetOperation(c78665705.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。发动后，这个回合中自己把「太阳神之翼神龙」上级召唤的场合，那个原本的攻击力·守备力变成因为那次上级召唤而解放的怪兽的原本的攻击力·守备力各自合计数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78665705,1))  --"准备改变攻守"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 把墓地的这张卡除外作为发动的代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c78665705.gaintg)
	e2:SetOperation(c78665705.gainop)
	c:RegisterEffect(e2)
end
-- 过滤卡组或墓地中可以加入手卡的「太阳神之翼神龙」。
function c78665705.filter(c)
	return c:IsCode(10000010) and c:IsAbleToHand()
end
-- 效果①发动的可行性检测（检查卡组或墓地是否有「太阳神之翼神龙」，且玩家是否可以进行通常召唤和追加召唤，且本回合未适用过此效果）。
function c78665705.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组或墓地是否存在可以加入手卡的「太阳神之翼神龙」。
	if chk==0 then return Duel.IsExistingMatchingCard(c78665705.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
		-- 检查玩家是否可以进行通常召唤以及是否可以获得追加召唤次数。
		and Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp)
		-- 检查本回合是否尚未适用过此卡追加召唤的效果标识。
		and Duel.GetFlagEffect(tp,78665705)==0 end
	-- 设置将卡组或墓地的1张卡加入手卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果①的处理（检索「太阳神之翼神龙」并赋予本回合追加上级召唤的效果）。
function c78665705.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地选择1张「太阳神之翼神龙」（受王家长眠之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c78665705.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
		if g:GetFirst():IsLocation(LOCATION_HAND) then
			-- 检查是否满足赋予追加上级召唤效果的条件。
			if Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp) and Duel.GetFlagEffect(tp,78665705)==0 then
				-- 这个回合自己在通常召唤外加上只有1次，自己主要阶段可以上级召唤。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetDescription(aux.Stringid(78665705,2))  --"使用「古之咒文」的效果上级召唤"
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetTargetRange(LOCATION_HAND,0)
				e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
				e1:SetValue(0x1)
				e1:SetReset(RESET_PHASE+PHASE_END)
				-- 注册增加通常召唤（上级召唤）次数的效果。
				Duel.RegisterEffect(e1,tp)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_EXTRA_SET_COUNT)
				-- 注册增加通常召唤（里侧表示上级召唤）次数的效果。
				Duel.RegisterEffect(e2,tp)
				-- 给玩家注册本回合已适用追加召唤效果的标识。
				Duel.RegisterFlagEffect(tp,78665705,RESET_PHASE+PHASE_END,0,1)
			end
		end
	end
end
-- 效果②发动的可行性检测（检查本回合是否尚未发动过此效果）。
function c78665705.gaintg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否尚未注册过此效果的标识。
	if chk==0 then return Duel.GetFlagEffect(tp,78665706)==0 end
end
-- 效果②的处理（注册解放怪兽攻守合计值加成给太阳神之翼神龙的系统效果）。
function c78665705.gainop(e,tp,eg,ep,ev,re,r,rp)
	-- 若本回合已注册过此效果的标识，则不重复处理。
	if Duel.GetFlagEffect(tp,78665706)~=0 then return end
	local c=e:GetHandler()
	-- 那个原本的攻击力·守备力变成因为那次上级召唤而解放的怪兽的原本的攻击力·守备力各自合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
	e1:SetValue(c78665705.valcheck)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册用于检测上级召唤解放素材的全局效果。
	Duel.RegisterEffect(e1,tp)
	-- 发动后，这个回合中自己把「太阳神之翼神龙」上级召唤的场合，那个原本的攻击力·守备力变成因为那次上级召唤而解放的怪兽的原本的攻击力·守备力各自合计数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SUMMON_COST)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetTarget(c78665705.tgchk)
	e2:SetOperation(c78665705.facechk)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetLabelObject(e1)
	-- 注册用于在召唤「太阳神之翼神龙」时触发攻守数值变更的全局效果。
	Duel.RegisterEffect(e2,tp)
	-- 给玩家注册本回合已发动此效果的标识。
	Duel.RegisterFlagEffect(tp,78665706,RESET_PHASE+PHASE_END,0,1)
end
-- 计算解放怪兽的原本攻击力与守备力合计值，并将其作为原本攻守数值赋予召唤出的怪兽。
function c78665705.valcheck(e,c)
	if e:GetLabel()==1 then
		e:SetLabel(0)
		local g=c:GetMaterial()
		local tc=g:GetFirst()
		local atk=0
		local def=0
		while tc do
			atk=atk+math.max(tc:GetTextAttack(),0)
			def=def+math.max(tc:GetTextDefense(),0)
			tc=g:GetNext()
		end
		-- 那个原本的攻击力·守备力变成因为那次上级召唤而解放的怪兽的原本的攻击力·守备力各自合计数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		e2:SetValue(def)
		c:RegisterEffect(e2)
	end
end
-- 过滤需要适用此效果的怪兽（「太阳神之翼神龙」）。
function c78665705.tgchk(e,c)
	return c:IsCode(10000010)
end
-- 在召唤「太阳神之翼神龙」时，将素材检测效果的Label设为1以启用攻守变更。
function c78665705.facechk(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(1)
end

--ライゼオル・クロス
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己若非同名卡不在自己场上存在的怪兽则不能超量召唤。
-- ②：以「雷火沸动交界机」以外的自己墓地2张「雷火沸动」卡为对象才能发动。那些卡用喜欢的顺序回到卡组下面。那之后，自己抽1张。
-- ③：1回合1次，对方发动的怪兽的效果的处理时，自己可以把自己场上的「雷火沸动」超量怪兽1个超量素材取除。那个场合，那个效果无效化。
local s,id,o=GetID()
-- 初始化卡片效果：注册允许发动的空效果（永续/场地卡发动所必需）、①的超量召唤限制永续效果、②的墓地回收加抽卡起动效果（1回合1次）、③的对方怪兽效果处理时无效的不入连锁永续效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：自己若非同名卡不在自己场上存在的怪兽则不能超量召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	c:RegisterEffect(e1)
	-- ②：以「雷火沸动交界机」以外的自己墓地2张「雷火沸动」卡为对象才能发动。那些卡用喜欢的顺序回到卡组下面。那之后，自己抽1张。这个卡名的②的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收并抽卡"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，对方发动的怪兽的效果的处理时，自己可以把自己场上的「雷火沸动」超量怪兽1个超量素材取除。那个场合，那个效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"无效"
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.discon)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
-- 定义过滤函数：卡片为表侧表示且卡名为指定卡名（即场上存在同名卡）
function s.spfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 定义超量召唤限制函数：仅对超量召唤生效，且自己场上已存在与该怪兽同名的表侧表示卡时禁止该次超量召唤
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	-- 若召唤方式为超量召唤且自己场上存在与要超量召唤的怪兽同名的表侧表示卡，则禁止该次超量召唤
	return sumtype==SUMMON_TYPE_XYZ and Duel.IsExistingMatchingCard(s.spfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil,c:GetCode())
end
-- 定义回收对象过滤函数：墓地的、卡名不是「雷火沸动交界机」的「雷火沸动」卡且可以回到卡组
function s.tdfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1be) and c:IsAbleToDeck() and c:IsLocation(LOCATION_GRAVE)
end
-- ②效果的对象选择函数：连锁对象合法性检查，并检查能否发动——自己可以抽1张卡且自己墓地存在2张满足条件的可作为对象的卡
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 发动条件检查：自己可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 且自己墓地存在2张满足条件的、可以成为效果对象的「雷火沸动」卡
		and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 向玩家发送选择提示：请选择要回到卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让自己选择自己墓地2张满足条件的卡作为效果对象
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置操作信息：这2张对象卡将回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	-- 设置操作信息：自己将抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果的处理：取与连锁关联的对象卡中不受王家长眠之谷影响的卡，把它们按喜欢的顺序回到卡组下面，若至少有1张成功回到卡组或额外卡组，则中断时点后自己抽1张卡
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得与本连锁关联的对象卡，并过滤掉受王家长眠之谷影响的卡
	local tg=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if #tg>0 then
		-- 让自己把这些卡按喜欢的顺序放回卡组下面，并记录成功放回的数量
		local ct=aux.PlaceCardsOnDeckBottom(tp,tg)
		if ct>0 and tg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then
			-- 中断当前效果处理，使之后的抽卡视为不同时处理（避免错时点问题）
			Duel.BreakEffect()
			-- 自己以效果原因抽1张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
-- 定义取除素材对象过滤函数：自己场上表侧表示的「雷火沸动」超量怪兽，且可以取除1个超量素材
function s.disfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x1be) and c:IsFaceup() and c:CheckRemoveOverlayCard(c:GetControler(),1,REASON_EFFECT)
end
-- ③效果的适用条件：连锁的效果由对方发动、是怪兽效果、可以被无效，自己场上存在可取除超量素材的「雷火沸动」超量怪兽，且本回合尚未使用过此效果
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断该连锁由对方发动、效果可以被无效、且发动的是怪兽的效果
	return rp==1-tp and Duel.IsChainDisablable(ev) and re:IsActiveType(TYPE_MONSTER)
		-- 且自己场上存在1只可以取除1个超量素材的表侧表示「雷火沸动」超量怪兽
		and Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():GetFlagEffect(id)<=0
end
-- ③效果的处理：询问自己是否适用无效效果，若适用则选择自己场上1只「雷火沸动」超量怪兽并取除其1个超量素材，成功后将对方那个怪兽效果无效化，并注册标志表示本回合已使用过此效果
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 询问自己是否适用「雷火沸动交界机」的效果将对方的效果无效
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,3)) then  --"是否适用「雷火沸动交界机」的效果来无效？"
		-- 向玩家发送选择提示：请选择要取除超量素材的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)  --"请选择要取除超量素材的怪兽"
		-- 让自己选择自己场上1只满足条件的「雷火沸动」超量怪兽
		local tc=Duel.SelectMatchingCard(tp,s.disfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if tc and tc:RemoveOverlayCard(tp,1,1,REASON_EFFECT) then
			-- 向双方显示本卡的卡片动画，提示此效果已适用
			Duel.Hint(HINT_CARD,0,id)
			-- 将对方发动的那个怪兽效果无效化
			Duel.NegateEffect(ev)
			e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))  --"已使用过无效怪兽的效果"
		end
	end
end

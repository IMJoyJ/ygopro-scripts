--ライゼオル・クロス
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己若非同名卡不在自己场上存在的怪兽则不能超量召唤。
-- ②：以「雷火沸动交界机」以外的自己墓地2张「雷火沸动」卡为对象才能发动。那些卡用喜欢的顺序回到卡组下面。那之后，自己抽1张。
-- ③：1回合1次，对方发动的怪兽的效果的处理时，自己可以把自己场上的「雷火沸动」超量怪兽1个超量素材取除。那个场合，那个效果无效化。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
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
	-- ②：以「雷火沸动交界机」以外的自己墓地2张「雷火沸动」卡为对象才能发动。那些卡用喜欢的顺序回到卡组下面。那之后，自己抽1张。
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
-- 过滤场上与指定卡片同密码且表侧表示的怪兽
function s.spfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 超量召唤的限制判定
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	-- 若为超量召唤且场上已存在欲召唤的同名怪兽，则限制其特殊召唤
	return sumtype==SUMMON_TYPE_XYZ and Duel.IsExistingMatchingCard(s.spfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil,c:GetCode())
end
-- 过滤自己墓地中除自身以外可以回到卡组的「雷火沸动」卡片
function s.tdfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1be) and c:IsAbleToDeck() and c:IsLocation(LOCATION_GRAVE)
end
-- 效果②（回到卡组并抽卡）的发动检测与对象选择
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 在发动准备阶段检测玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检测自己墓地是否存在至少2张符合条件的「雷火沸动」卡片
		and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地2张符合条件的「雷火沸动」卡片作为效果对象
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置效果处理的操作信息为将选中的卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	-- 设置效果处理的操作信息为玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②（回到卡组并抽卡）的效果处理函数
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中仍与效果有关联且不受王家长眠之谷影响的对象卡片
	local tg=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if #tg>0 then
		-- 将选择的卡片以喜欢的顺序放到卡组底端
		local ct=aux.PlaceCardsOnDeckBottom(tp,tg)
		if ct>0 and tg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then
			-- 中断当前效果，使后续的抽卡处理不与回到卡组同时进行
			Duel.BreakEffect()
			-- 让玩家从卡组抽1张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
-- 过滤自己场上表侧表示、拥有超量素材且为「雷火沸动」的超量怪兽
function s.disfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x1be) and c:IsFaceup() and c:CheckRemoveOverlayCard(c:GetControler(),1,REASON_EFFECT)
end
-- 效果③（对方怪兽效果无效）的发动时机判定条件
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定是否为对方玩家发动的可以被无效的怪兽效果
	return rp==1-tp and Duel.IsChainDisablable(ev) and re:IsActiveType(TYPE_MONSTER)
		-- 检测己方场上是否存在符合条件且拥有超量素材的「雷火沸动」超量怪兽
		and Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():GetFlagEffect(id)<=0
end
-- 效果③（对方怪兽效果无效）的处理函数
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 询问玩家是否适用此卡效果将对方的怪兽效果无效化
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,3)) then  --"是否适用「雷火沸动交界机」的效果来无效？"
		-- 提示玩家选择要取除超量素材的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)  --"请选择要取除超量素材的怪兽"
		-- 选择己方场上1只符合条件的「雷火沸动」超量怪兽
		local tc=Duel.SelectMatchingCard(tp,s.disfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if tc and tc:RemoveOverlayCard(tp,1,1,REASON_EFFECT) then
			-- 在场上展示此卡卡片以提示效果被应用
			Duel.Hint(HINT_CARD,0,id)
			-- 使该连锁中的对方怪兽效果无效
			Duel.NegateEffect(ev)
			e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))  --"已使用过无效怪兽的效果"
		end
	end
end

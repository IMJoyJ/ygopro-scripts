--凶導の白き天底
-- 效果：
-- 「凶导的福音」降临
-- 这张卡不用「教导」卡的效果不能仪式召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的「教导」怪兽不受对方发动的融合·同调·超量·连接怪兽的效果影响。
-- ②：自己主要阶段才能发动。对方从以下效果把1个适用。
-- ●自身的额外卡组的卡每有2张，从自身的手卡·额外卡组选1张卡送去墓地。
-- ●自身场上的融合·同调·超量·连接怪兽全部回到额外卡组。
local s,id,o=GetID()
-- 初始化卡片效果：注册特殊召唤限制条件，自己场上的「教导」怪兽不受对方发动的特定怪兽效果影响的永续效果，以及让对方二选一适用的起动效果
function s.initial_effect(c)
	-- 将「凶导的福音」(31002402)加入该卡的关联卡片密码列表中
	aux.AddCodeList(c,31002402)
	c:EnableReviveLimit()
	-- 这张卡不用「教导」卡的效果不能仪式召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- ①：自己场上的「教导」怪兽不受对方发动的融合·同调·超量·连接怪兽的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置免疫效果的受影响目标为自己场上的「教导」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x145))
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。对方从以下效果把1个适用。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOEXTRA)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
-- 仪式召唤限制的判定：非仪式召唤不受限制，或者是用「教导」卡的效果发动的仪式召唤
function s.splimit(e,se,sp,st)
	return st&SUMMON_TYPE_RITUAL~=SUMMON_TYPE_RITUAL or (se and se:GetHandler():IsSetCard(0x145))
end
-- 判定不受影响的条件：来源是对方玩家发动的且是融合、同调、超量、连接怪兽的效果
function s.efilter(e,re)
	return re:GetOwnerPlayer()~=e:GetOwnerPlayer() and re:IsActivated()
		and re:IsActiveType(TYPE_MONSTER) and re:IsActiveType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
-- 过滤对方场上表侧表示的融合、同调、超量、连接怪兽
function s.tefilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
-- 起动效果发动的可行性判定：若对方满足额外卡组数且有足够手卡/额外卡组卡片送去墓地，或者对方场上有可以回到额外卡组的融合/同调/超量/连接怪兽，则可以发动
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方额外卡组的卡片数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)
	-- 过滤并获取对方场上表侧表示的融合、同调、超量、连接怪兽组成的卡片组
	local g=Duel.GetMatchingGroup(s.tefilter,tp,0,LOCATION_MZONE,nil)
	-- 判定对方额外卡组卡片是否在2张以上，且对方手卡和额外卡组是否有足够数量（额外卡组数除以2向下取整）可送去墓地的卡
	local b1=ct>=2 and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_HAND+LOCATION_EXTRA,math.floor(ct/2),nil)
	-- 判定对方场上是否有融合、同调、超量、连接怪兽且它们是否全都能回到额外卡组
	local b2=#g>0 and not g:IsExists(aux.NOT(Card.IsAbleToExtra),1,nil)
	if chk==0 then return b1 or b2 end
end
-- 效果处理：计算对方额外卡组数与场上符合条件的怪兽，让对方从两个适用效果中选择一个合法效果并执行相应处理
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方额外卡组的卡片数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)
	local halfct=math.floor(ct/2)
	-- 过滤并获取对方场上表侧表示的融合、同调、超量、连接怪兽组成的卡片组
	local g=Duel.GetMatchingGroup(s.tefilter,tp,0,LOCATION_MZONE,nil)
	-- 判定对方额外卡组卡片是否在2张以上，且对方手卡和额外卡组是否有足够数量可送去墓地的卡
	local b1=ct>=2 and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_HAND+LOCATION_EXTRA,halfct,nil)
	-- 判定对方场上是否有融合、同调、超量、连接怪兽且它们是否全都能回到额外卡组
	local b2=#g>0 and not g:IsExists(aux.NOT(Card.IsAbleToExtra),1,nil)
	if not b1 and not b2 then return end
	local off=1
	local ops={}
	local opval={}
	if b1 then
		ops[off]=aux.Stringid(id,1)  --"从手卡·额外卡组选1张卡送去墓地"
		opval[off]=0
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(id,2)  --"场上的融合·同调·超量·连接怪兽全部回到额外卡组"
		opval[off]=1
		off=off+1
	end
	-- 让对方玩家从当前满足适用条件的效果中选择一项
	local op=Duel.SelectOption(1-tp,table.unpack(ops))+1
	local sel=opval[op]
	if sel==0 then
		-- 在界面上提示对方玩家选择要送去墓地的卡片
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让对方玩家从自身的手卡·额外卡组选择指定数量（额外卡组每有2张选1张）的可送墓卡片
		local g=Duel.SelectMatchingCard(1-tp,Card.IsAbleToGrave,tp,0,LOCATION_HAND+LOCATION_EXTRA,halfct,halfct,nil)
		if #g>0 then
			-- 将对方选中的卡送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	elseif sel==1 then
		-- 将对方场上所有融合·同调·超量·连接怪兽全部回到额外卡组
		Duel.SendtoDeck(g:Filter(Card.IsAbleToExtra,nil),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

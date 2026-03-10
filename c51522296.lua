--凶導の白き天底
-- 效果：
-- 「凶导的福音」降临
-- 这张卡不用「教导」卡的效果不能仪式召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的「教导」怪兽不受对方发动的融合·同调·超量·连接怪兽的效果影响。
-- ②：自己主要阶段才能发动。对方从以下效果把1个适用。
-- ●自身的额外卡组的卡每有2张，从自身的手卡·额外卡组选1张卡送去墓地。
-- ●自身场上的融合·同调·超量·连接怪兽全部回到额外卡组。
local s,id,o=GetID()
-- 初始化卡片效果，设置仪式召唤限制、免疫效果和起动效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不用「教导」卡的效果不能仪式召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- 自己场上的「教导」怪兽不受对方发动的融合·同调·超量·连接怪兽的效果影响
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 筛选场上的「教导」怪兽作为目标
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x145))
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次
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
-- 判断是否满足仪式召唤条件，即必须通过「教导」卡的效果进行仪式召唤
function s.splimit(e,se,sp,st)
	return st&SUMMON_TYPE_RITUAL~=SUMMON_TYPE_RITUAL or (se and se:GetHandler():IsSetCard(0x145))
end
-- 过滤对方发动的融合·同调·超量·连接怪兽效果，使其无法影响己方「教导」怪兽
function s.efilter(e,re)
	return re:GetOwnerPlayer()~=e:GetOwnerPlayer() and re:IsActivated()
		and re:IsActiveType(TYPE_MONSTER) and re:IsActiveType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
-- 筛选场上的融合·同调·超量·连接怪兽作为目标
function s.tefilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
-- 判断是否满足②效果的发动条件，即额外卡组有2张以上且手牌/额外卡组有足够数量的卡可送去墓地，或场上有融合·同调·超量·连接怪兽可返回额外卡组
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方额外卡组的卡数
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)
	-- 获取己方场上的融合·同调·超量·连接怪兽
	local g=Duel.GetMatchingGroup(s.tefilter,tp,0,LOCATION_MZONE,nil)
	-- 判断是否满足选项一条件：额外卡组有2张以上且手牌/额外卡组有足够数量的卡可送去墓地
	local b1=ct>=2 and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_HAND+LOCATION_EXTRA,math.floor(ct/2),nil)
	-- 判断是否满足选项二条件：场上有融合·同调·超量·连接怪兽且均可返回额外卡组
	local b2=#g>0 and not g:IsExists(aux.NOT(Card.IsAbleToExtra),1,nil)
	if chk==0 then return b1 or b2 end
end
-- 执行②效果的操作，由对方选择使用哪个效果
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方额外卡组的卡数
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)
	local halfct=math.floor(ct/2)
	-- 获取己方场上的融合·同调·超量·连接怪兽
	local g=Duel.GetMatchingGroup(s.tefilter,tp,0,LOCATION_MZONE,nil)
	-- 判断是否满足选项一条件：额外卡组有2张以上且手牌/额外卡组有足够数量的卡可送去墓地
	local b1=ct>=2 and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_HAND+LOCATION_EXTRA,halfct,nil)
	-- 判断是否满足选项二条件：场上有融合·同调·超量·连接怪兽且均可返回额外卡组
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
	-- 让对方选择使用哪个效果
	local op=Duel.SelectOption(1-tp,table.unpack(ops))+1
	local sel=opval[op]
	if sel==0 then
		-- 提示对方选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 由对方从手牌/额外卡组选择指定数量的卡送去墓地
		local g=Duel.SelectMatchingCard(1-tp,Card.IsAbleToGrave,tp,0,LOCATION_HAND+LOCATION_EXTRA,halfct,halfct,nil)
		if #g>0 then
			-- 将选中的卡送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	elseif sel==1 then
		-- 将场上的融合·同调·超量·连接怪兽送回额外卡组
		Duel.SendtoDeck(g:Filter(Card.IsAbleToExtra,nil),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

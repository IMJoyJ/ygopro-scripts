--道化の一座 ディアボロ
-- 效果：
-- 相同属性而种族不同的怪兽×2
-- ①：上级召唤的自己怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的2倍数值的战斗伤害。
-- ②：这张卡被解放的场合，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●双方的场上·墓地的融合怪兽全部回到额外卡组。
-- ●从卡组把1张「道化一座」陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化卡片效果：设置苏生限制、添加融合召唤手续（同属性不同种族怪兽×2）、注册①贯穿伤害效果和②解放时选发效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：使用2只满足s.ffilter条件的怪兽作为融合素材，并允许使用融合素材代用品。
	aux.AddFusionProcFunRep(c,s.ffilter,2,true)
	-- ①：上级召唤的自己怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的2倍数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置贯穿效果的适用对象：我方场上通过上级召唤方式出场的怪兽（Card.IsSummonType判定召唤类型为上级召唤）。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSummonType,SUMMON_TYPE_ADVANCE))
	e1:SetValue(DOUBLE_DAMAGE)
	c:RegisterEffect(e1)
	-- ②：这张卡被解放的场合，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"选择效果"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 融合素材过滤函数：用于选择素材时判断候选怪兽是否可作为融合素材，实现“相同属性而种族不同的怪兽×2”的素材条件。
function s.ffilter(c,fc,sub,mg,sg)
	-- 当尚未选择任何素材（sg为空）时返回true，即第一只素材怪兽可以任意选择。
	return not sg or sg:FilterCount(aux.TRUE,c)==0
		or (sg:IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute())
			and not sg:IsExists(Card.IsRace,1,c,c:GetRace()))
end
-- 筛选可回额外卡组的融合怪兽：双方场上或墓地的表侧融合怪兽，且满足能够返回卡组的条件。
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_FUSION) and c:IsAbleToDeck()
end
-- 筛选可盖放的「道化一座」陷阱卡：卡名含有「道化一座」字段、类型为陷阱卡且当前可以盖放。
function s.setfilter(c)
	return c:IsSetCard(0x1dc) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- ②效果的发动条件判定与选项选择：分别检查“回收融合怪兽”和“盖放陷阱”是否可用，由玩家选择其中一个；同时设置对应类别、回合限制标记和操作信息。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方场上·墓地是否存在至少1张可返回额外卡组的融合怪兽，作为选项1“回收融合怪兽”的可用条件。
	local b1=Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,1,nil)
		-- 若已进行代价确认，则追加判定本回合尚未使用过“回收融合怪兽”选项（用id标记），确保同名卡该选项1回合1次。
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	-- 检查我方魔陷区是否有空位，作为选项2“盖放陷阱”的可用前提。
	local b2=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查我方卡组是否存在至少1张满足条件的「道化一座」陷阱卡，作为选项2的可用条件。
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
		-- 若已进行代价确认，则追加判定本回合尚未使用过“盖放陷阱”选项（用id+o标记），确保同名卡该选项1回合1次。
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o)==0)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 调用选项选择函数，让玩家从当前可用的两个效果中选择1个发动，返回值存入变量op。
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"回收融合怪兽"
			{b2,aux.Stringid(id,2),2})  --"盖放陷阱卡"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TODECK)
			-- 注册玩家标记id，持续到结束阶段重置，表示本回合已使用过“回收融合怪兽”选项，用于同名卡1回合1次的限制。
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 取得双方场上·墓地所有满足s.tdfilter的融合怪兽，作为本效果准备返回额外卡组的对象集合。
		local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,nil)
		-- 设置操作信息：声明本次连锁将把g中的所有卡（双方场上·墓地的融合怪兽）返回卡组，数量为g中卡数，位置为墓地+场上。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,LOCATION_GRAVE+LOCATION_MZONE)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SSET)
			-- 注册玩家标记id+o，持续到结束阶段重置，表示本回合已使用过“盖放陷阱”选项，用于同名卡1回合1次的限制。
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
-- ②效果的实际处理：若选择了选项1，则将双方场上·墓地的融合怪兽全部洗回额外卡组（受王家长眠之谷限制时中止）；若选择了选项2，则从卡组选1张「道化一座」陷阱卡盖放到我方魔陷区。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==1 then
		-- 效果处理时重新取得双方场上·墓地所有满足s.tdfilter的融合怪兽，确保操作对象为当前仍符合条件的卡。
		local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,nil)
		-- 若对象中存在受王家长眠之谷影响的卡且当前连锁可被无效，则自动无效并中止本效果的后续处理。
		if aux.NecroValleyNegateCheck(g) then return end
		-- 将g中的所有融合怪兽以效果原因送回持有者的额外卡组，并洗切卡组（SEQ_DECKSHUFFLE表示弹回卡组并洗牌）。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	elseif e:GetLabel()==2 then
		-- 效果处理时再次确认我方魔陷区仍有空位；若没有空位则无法盖放，直接终止本分支。
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		-- 给玩家发送选择提示消息，提示内容为“请选择要盖放的卡”，用于卡片选择界面的显示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组中选择1张满足s.setfilter条件的「道化一座」陷阱卡，作为要盖放到场上的卡。
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 将选中的陷阱卡以里侧表示盖放到我方魔陷区（SSet执行盖放）。
			Duel.SSet(tp,tc)
		end
	end
end

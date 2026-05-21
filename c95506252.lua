--影装騎士 ブラック・ジャック
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡不会被战斗破坏。
-- ②：每次对方的魔法与陷阱区域有卡被放置发动。直到怪兽出现为止从自己卡组上面翻卡，那只怪兽当作装备魔法卡使用给这张卡装备。剩余用喜欢的顺序回到卡组下面。
-- ③：这张卡的攻击力·守备力上升给这张卡装备的怪兽的等级合计×300。
-- ④：给这张卡装备的怪兽的等级合计比21星大的场合这张卡破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含同调召唤手续、战破抗性、翻卡装备、攻守上升、自我破坏等效果
function s.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：每次对方的魔法与陷阱区域有卡被放置发动。直到怪兽出现为止从自己卡组上面翻卡，那只怪兽当作装备魔法卡使用给这张卡装备。剩余用喜欢的顺序回到卡组下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"装备效果"
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_MOVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.eqcon)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	-- ③：这张卡的攻击力·守备力上升给这张卡装备的怪兽的等级合计×300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.adval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- ④：给这张卡装备的怪兽的等级合计比21星大的场合这张卡破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_SELF_DESTROY)
	e5:SetCondition(s.descon)
	c:RegisterEffect(e5)
end
-- 过滤移动到对方魔法与陷阱区域（非场地区）的卡片
function s.desfilter(c,tp)
	return c:IsLocation(LOCATION_SZONE) and c:IsControler(1-tp) and c:GetSequence()<5
end
-- 检查是否有卡片被放置到对方的魔法与陷阱区域，作为效果②的发动条件
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.desfilter,1,e:GetHandler(),tp)
end
-- 效果②的发动准备，设置从卡组装备卡片的操作信息
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为：从卡组将1张卡装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,0,LOCATION_DECK)
end
-- 过滤可以作为装备卡装备给这张卡的怪兽卡
function s.eqfilter(c,tc,tp)
	return c:IsType(TYPE_MONSTER)
		and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- 翻开并确认自己卡组最上方指定数量的卡片（若数量大于5则向对方展示，否则仅自己确认）
function s.confirm_decktop_s(tp,count)
	local max_decktop=5
	if count>max_decktop then
		-- 获取自己卡组最上方的指定数量的卡片组
		local g=Duel.GetDecktopGroup(tp,count)
		-- 将获取的卡片组给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	else
		-- 确认自己卡组最上方的指定数量的卡片
		Duel.ConfirmDecktop(tp,count)
	end
end
-- 效果②的处理：从卡组最上方开始翻卡直到怪兽出现，将该怪兽装备给这张卡，其余卡片按喜好顺序放回卡组最下方
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己卡组中所有的怪兽卡
	local mg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_DECK,0,nil,TYPE_MONSTER)
	-- 若卡组中没有怪兽卡，或者自己的魔法与陷阱区域没有空位，则不处理效果
	if mg:GetCount()==0 or Duel.GetLocationCount(tp,LOCATION_SZONE)==0 then return end
	-- 获取自己卡组的卡片总数
	local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local seq=-1
	local tc=mg:GetFirst()
	local qc=nil
	while tc do
		if tc:GetSequence()>seq then
			seq=tc:GetSequence()
			qc=tc
		end
		tc=mg:GetNext()
	end
	if seq==-1 then
		return
	end
	s.confirm_decktop_s(tp,dcount-seq)
	-- 获取翻出的怪兽卡之上的所有非怪兽卡（即需要放回卡组底部的卡片组）
	local cg=Duel.GetDecktopGroup(tp,dcount-seq-1)
	if c:IsRelateToChain() and c:IsFaceup() and qc then
		-- 禁用接下来的洗牌检测，防止因从卡组取出卡片而自动洗牌
		Duel.DisableShuffleCheck()
		if s.eqfilter(qc,c,tp) then
			-- 尝试将翻出的怪兽卡作为装备卡装备给这张卡
			if Duel.Equip(tp,qc,c) then
				-- 那只怪兽当作装备魔法卡使用给这张卡装备。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetLabelObject(c)
				e1:SetValue(s.eqlimit)
				qc:RegisterEffect(e1)
			end
		else
			-- 若翻出的怪兽无法装备，则根据规则送去墓地
			Duel.SendtoGrave(qc,REASON_RULE)
		end
	elseif qc then
		-- 若这张卡已不在场或不是表侧表示，则将翻出的怪兽根据规则送去墓地
		Duel.SendtoGrave(qc,REASON_RULE)
	end
	if #cg>0 then
		-- 让玩家对翻出的非怪兽卡片组进行排序
		Duel.SortDecktop(tp,tp,#cg)
		for i=1,#cg do
			-- 获取排序后卡组最上方的一张卡
			local mvg=Duel.GetDecktopGroup(tp,1)
			-- 将该卡片移动到卡组最下方
			Duel.MoveSequence(mvg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
-- 装备限制：只能装备给这张卡
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 过滤原本是怪兽卡的装备卡
function s.cqfilter(c)
	return c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER
end
-- 计算并返回给这张卡装备的怪兽的等级合计×300的数值
function s.adval(e,c)
	local eg=c:GetEquipGroup():Filter(s.cqfilter,nil)
	return eg:GetSum(Card.GetOriginalLevel)*300
end
-- 检查给这张卡装备的怪兽的等级合计是否大于21，作为自我破坏效果的条件
function s.descon(e)
	local eg=e:GetHandler():GetEquipGroup():Filter(s.cqfilter,nil)
	return eg:GetSum(Card.GetOriginalLevel)>21
end

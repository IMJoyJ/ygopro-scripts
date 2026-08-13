--黒薔薇の魔女
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：自己场上没有其他卡存在，这张卡召唤成功的场合发动。自己从卡组抽1张，给双方确认。那是怪兽以外的场合，那张卡送去墓地，这张卡破坏。
function c17720747.initial_effect(c)
	-- 这张卡不能特殊召唤。（效果外文本）
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：自己场上没有其他卡存在，这张卡召唤成功的场合发动。自己从卡组抽1张，给双方确认。那是怪兽以外的场合，那张卡送去墓地，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17720747,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(c17720747.condition)
	e2:SetTarget(c17720747.target)
	e2:SetOperation(c17720747.operation)
	c:RegisterEffect(e2)
end
-- 诱发效果的发动的条件判断函数：判断自己场上是否存在这张卡以外的其他卡。
function c17720747.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定己方场上全部卡数量是否小于等于1（即只有这张卡自身，没有其他卡存在）。
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)<=1
end
-- 发动时的目标处理：此效果不取对象，直接允许发动并设置抽卡操作信息。
function c17720747.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次连锁的操作信息设为“抽1张卡”，供其他效果进行连锁判定或对应。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：从卡组顶抽1张并给双方确认；若该卡不是怪兽，则将其送去墓地，再将这张卡破坏；最后洗切手卡。
function c17720747.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组最上方的1张卡，作为即将抽到的卡。
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	-- 自己以效果原因抽1张卡。
	Duel.Draw(tp,1,REASON_EFFECT)
	if tc then
		-- 将抽到的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,tc)
		if not tc:IsType(TYPE_MONSTER) then
			-- 中断当前效果处理，使后续送墓和破坏视为独立处理，避免时点错误。
			Duel.BreakEffect()
			-- 将抽到的那张卡（非怪兽卡）送去墓地。
			Duel.SendtoGrave(tc,REASON_EFFECT)
			if e:GetHandler():IsRelateToEffect(e) then
				-- 将这张“黑蔷薇之魔女”自身破坏。
				Duel.Destroy(e:GetHandler(),REASON_EFFECT)
			end
		end
		-- 洗切手卡，重置手卡顺序相关的状态。
		Duel.ShuffleHand(tp)
	end
end

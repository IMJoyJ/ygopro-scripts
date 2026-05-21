--席取－六双丸
-- 效果：
-- 6星怪兽×2
-- ①：对方战斗阶段开始时发动。掷1次骰子。双方的主要怪兽区域从这张卡来看以顺时针转法从下1区算起作为1～6，主要怪兽区域的这张卡向出现数目字的区域移动。所去移动区有怪兽存在的场合，那只在这下面重叠作为超量素材（持有超量素材的怪兽的场合那些也全部重叠）。这超量素材超过6个时，自己决斗胜利。不能移动的场合或者不能把在所去移动区的怪兽作为超量素材的场合，这张卡送去墓地。
function c96637156.initial_effect(c)
	-- 为这张卡添加超量召唤手续：6星怪兽×2
	aux.AddXyzProcedure(c,nil,6,2)
	c:EnableReviveLimit()
	-- ①：对方战斗阶段开始时发动。掷1次骰子。双方的主要怪兽区域从这张卡来看以顺时针转法从下1区算起作为1～6，主要怪兽区域的这张卡向出现数目字的区域移动。不能移动的场合或者不能把在所去移动区的怪兽作为超量素材的场合，这张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96637156,0))
	e1:SetCategory(CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c96637156.movcon)
	e1:SetTarget(c96637156.movtg)
	e1:SetOperation(c96637156.movop)
	c:RegisterEffect(e1)
end
-- 定义①效果的发动条件函数
function c96637156.movcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 定义①效果的发动准备（Target）函数
function c96637156.movtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理的操作信息为：玩家掷1次骰子
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 定义①效果的效果处理函数的前半部分：掷骰子、计算移动目标区域并进行无法移动时的送墓判定
function c96637156.movop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:GetSequence()>=5 then return end
	local winflag=c:GetOverlayCount()<=6
	-- 让玩家掷1次骰子，并获取骰子的结果
	local dice=Duel.TossDice(tp,1)
	if dice<1 or dice>6 then return end
	local p=tp
	local seq=c:GetSequence()-dice
	while seq<0 do
		seq=seq+5
		p=1-p
	end
	local zone=1<<seq
	-- 获取计算出的目标移动区域上的怪兽
	local tc=Duel.GetFieldCard(p,LOCATION_MZONE,seq)
	if p~=tp and not c:IsControlerCanBeChanged(true)
		-- 判断目标区域是否无法容纳移动过来的这张卡
		or Duel.GetMZoneCount(p,tc,tp,LOCATION_REASON_CONTROL,zone)<=0
		or tc and (not tc:IsCanOverlay(p) or tc:IsImmuneToEffect(e)) then
		-- 因效果无法执行，将这张卡送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	if tc then
		local og=tc:GetOverlayGroup()
		-- 若目标区域的怪兽持有超量素材，则将那些超量素材也全部重叠作为这张卡的超量素材
		if og:GetCount()>0 then Duel.Overlay(c,og) end
		-- 将目标区域的怪兽重叠作为这张卡的超量素材
		Duel.Overlay(c,tc)
	end
	if p==tp then
		-- 将这张卡移动到自己场上计算出的目标怪兽区域
		Duel.MoveSequence(c,seq)
	else
		-- 将这张卡移动到对方场上计算出的目标怪兽区域，并转移控制权
		Duel.GetControl(c,1-tp,0,0,zone)
	end
	local WIN_REASON_MUSOMARU=0x22
	-- 若原本超量素材不超过6个，而现在超量素材超过6个时，自己决斗胜利
	if winflag and c:GetOverlayCount()>6 then Duel.Win(tp,WIN_REASON_MUSOMARU) end
end

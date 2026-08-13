--メガリス・ベトール
-- 效果：
-- 「巨石遗物」卡降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「巨石遗物」仪式怪兽仪式召唤。
-- ②：这张卡仪式召唤成功的场合，以最多有自己墓地的仪式怪兽种类数量的对方场上的卡为对象才能发动。那些卡破坏。
function c99628747.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡创建①效果的仪式召唤处理：将这张卡在手上作为起动效果发动，通过解放手卡·场上的怪兽（等级合计可大于等于仪式怪兽等级），从手卡仪式召唤1只「巨石遗物」仪式怪兽；filter指定仪式怪兽必须为「巨石遗物」字段，matfilter限制素材不能是这张卡自身。
	local e1=aux.AddRitualProcGreater2(c,c99628747.filter,nil,nil,c99628747.matfilter,true)
	e1:SetDescription(aux.Stringid(99628747,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCode(0)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,99628747)
	e1:SetCost(c99628747.rscost)
	c:RegisterEffect(e1)
	-- ②：这张卡仪式召唤成功的场合，以最多有自己墓地的仪式怪兽种类数量的对方场上的卡为对象才能发动。那些卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99628747,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,99628748)
	e2:SetCondition(c99628747.descon)
	e2:SetTarget(c99628747.destg)
	e2:SetOperation(c99628747.desop)
	c:RegisterEffect(e2)
end
-- 仪式怪兽过滤函数：仪式召唤的怪兽必须属于「巨石遗物」字段（SetCard 0x138），且不能是发动效果的这张卡自身。
function c99628747.filter(c,e,tp,chk)
	return c:IsSetCard(0x138) and (not chk or c~=e:GetHandler())
end
-- 仪式召唤素材过滤函数：作为解放素材的怪兽不能是发动效果的这张卡自身（因为该卡已作为代价从手卡丢弃，不属于可用的素材）。
function c99628747.matfilter(c,e,tp,chk)
	return not chk or c~=e:GetHandler()
end
-- ①效果的发动代价函数：检查这张卡能否从手卡丢弃；可以则丢弃此卡作为发动代价。
function c99628747.rscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡从手卡送入墓地，原因记为‘代价+丢弃’（对应‘把这张卡从手卡丢弃才能发动’）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 墓地仪式怪兽的过滤函数：用于统计自己墓地中仪式怪兽的种类数量，只计算同时为仪式类型和怪兽类型的卡。
function c99628747.cfilter(c)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER)
end
-- ②效果的发动条件：这张卡以仪式召唤的方式特殊召唤成功时才能发动。
function c99628747.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- ②效果的目标设定函数：选择对方场上的卡为对象，数量为1到墓地仪式怪兽种类数之间；若选择对象时，只允许选择对方场上的卡；发动条件是自己墓地存在至少1只仪式怪兽且对方场上有卡。
function c99628747.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查自己墓地是否存在至少1只仪式怪兽（用于计算可选数量上限）。
	if chk==0 then return Duel.IsExistingMatchingCard(c99628747.cfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查对方场上是否存在至少1张可以成为对象的卡，满足发动条件。
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取自己墓地的全部仪式怪兽集合，用于统计种类数。
	local g=Duel.GetMatchingGroup(c99628747.cfilter,tp,LOCATION_GRAVE,0,nil)
	local gc=g:GetClassCount(Card.GetCode)
	-- 向当前玩家显示‘选择要破坏的卡’的提示，要求选择破坏对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的卡作为效果对象，选择数量为1到gc（墓地仪式怪兽种类数），并自动设为连锁对象。
	local sg=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,gc,nil)
	-- 将本次连锁的操作信息登记为破坏效果，记录要破坏的对象及数量，供后续处理与效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- ②效果处理函数：实际处理时，将仍与该效果相关的对象卡全部破坏。
function c99628747.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁所选择的对象，并筛选出仍与效果相关的卡（防止对象离场等情况）。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 以效果破坏的方式将筛选出的对象卡送入墓地。
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
